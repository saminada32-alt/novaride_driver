// lib/features/auth/services/auth_service.dart
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/auth_model.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/resilient_http.dart';
import '../../../../core/utils/auth_errors.dart';

class AuthService {
  AuthService._();
  static AuthService instance = AuthService._();
  static const _storage = FlutterSecureStorage();

  static const _h = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  Map<String, String> _auth(String t) => {..._h, 'Authorization': 'Bearer $t'};

  Future<void> sendOtp(
    String phone, {
    String role = 'DRIVER',
    bool forLogin = false,
  }) async {
    try {
      final body = <String, dynamic>{'phone': phone, 'role': role};
      if (forLogin) body['intent'] = 'login';

      final res = await ResilientHttp.authSendPost(
        Uri.parse('${Api.base}${Api.sendOtp}'),
        headers: _h,
        body: jsonEncode(body),
      );
      if (res.statusCode == 404) {
        throw authErrAccountNotFound;
      }
      final data = ResilientHttp.decodeJson(res);
      if (res.statusCode == 400 && data['code'] == 'SMS_DELIVERY_FAILED') {
        throw 'تعذّر إرسال SMS — حاول بعد قليل';
      }
      _check(res);
    } on SocketException {
      throw 'تعذّر الاتصال بالخادم — تحقق من الإنترنت';
    } on TimeoutException {
      throw 'الخادم تأخر في الرد — حاول مجدداً';
    }
  }

  Future<AuthResult> verifyOtp(
    String phone,
    String otp, {
    String role = 'DRIVER',
    List<Map<String, String>>? consents,
  }) async {
    try {
      final body = <String, dynamic>{'phone': phone, 'otp': otp, 'role': role};
      if (consents != null && consents.isNotEmpty) {
        body['consents'] = consents;
      }

      final res = await ResilientHttp.authPost(
        Uri.parse('${Api.base}${Api.verifyOtp}'),
        headers: _h,
        body: jsonEncode(body),
      );
      final data = _check(res);
      final r = AuthResult.fromJson(data);
      await _storage.write(key: 'driver_token', value: r.accessToken);
      return r;
    } on SocketException {
      throw 'تعذّر الاتصال بالخادم — تحقق من الإنترنت';
    } on TimeoutException {
      throw 'الخادم تأخر في الرد — حاول مجدداً';
    }
  }

  Future<void> updateStatus(String token, bool online) async {
    try {
      final res = await ResilientHttp.patch(
        Uri.parse('${Api.base}${Api.driverStatus}'),
        headers: _auth(token),
        body: jsonEncode({'isAvailable': online}),
      );
      _check(res);
    } on SocketException {
      throw 'تعذّر الاتصال بالخادم — تحقق من الإنترنت';
    } on TimeoutException {
      throw 'الخادم تأخر في الرد — حاول مجدداً';
    }
  }

  Future<DriverModel> getMe(String token, {bool session = false}) async {
    final uri = Uri.parse('${Api.base}${Api.driversMe}');
    final headers = _auth(token);
    final res = session
        ? await ResilientHttp.sessionGet(uri, headers: headers)
        : await ResilientHttp.get(uri, headers: headers);
    if (res.statusCode == 401) throw const SessionExpiredException();
    return DriverModel.fromJson(_check(res));
  }

  Future<void> updateDriver(String token, Map<String, dynamic> data) async {
    final res = await ResilientHttp.patch(
      Uri.parse('${Api.base}${Api.driversMe}'),
      headers: _auth(token),
      body: jsonEncode(data),
    );
    _check(res);
  }

  Future<void> submitApplication(String token) async {
    final res = await ResilientHttp.post(
      Uri.parse('${Api.base}${Api.submitApplication}'),
      headers: _auth(token),
    );
    _check(res);
  }

  Future<String?> getToken() => _storage.read(key: 'driver_token');
  Future<bool> isLoggedIn() async => (await getToken()) != null;
  Future<void> logout() => _storage.delete(key: 'driver_token');

  Map<String, dynamic> _check(http.Response res) {
    final data = ResilientHttp.decodeJson(res);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (data['data'] is Map<String, dynamic>) {
        return Map<String, dynamic>.from(data['data'] as Map<String, dynamic>);
      }
      return data;
    }

    final raw = data['message'] ?? data['error'] ?? data['errors'];
    if (data['code'] == 'ACCOUNT_NOT_FOUND') throw authErrAccountNotFound;
    if (raw is String && raw.isNotEmpty) throw raw;
    if (raw is List) throw raw.join(', ');
    if (raw is Map && raw['message'] != null) throw raw['message'].toString();
    if (res.statusCode == 401) throw 'Invalid or expired OTP';
    if (res.statusCode == 404) throw authErrAccountNotFound;
    throw 'Request failed (${res.statusCode})';
  }
}
