// lib/features/auth/services/auth_service.dart
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/auth_model.dart';
import '../../../../core/constants/api_constants.dart';

class AuthService {
  AuthService._();
  static AuthService instance = AuthService._();
  static const _storage = FlutterSecureStorage();

  static const _h = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Map<String, String> _auth(String t) => {..._h, 'Authorization': 'Bearer $t'};

  // ─── OTP ─────────────────────────────────────────────────
  Future<void> sendOtp(String phone, {String role = 'DRIVER'}) async {
    try {
      final res = await http
          .post(
            Uri.parse('${Api.base}${Api.sendOtp}'),
            headers: _h,
            body: jsonEncode({'phone': phone, 'role': role}),
          )
          .timeout(const Duration(seconds: 8));
      _check(res);
    } on SocketException {
      throw 'لا يوجد اتصال — تأكد من الشبكة';
    } on TimeoutException {
      throw 'السيرفر لا يستجيب — تحقق من الـ IP';
    }
  }

  Future<AuthResult> verifyOtp(
    String phone,
    String otp, {
    String role = 'DRIVER',
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('${Api.base}${Api.verifyOtp}'),
            headers: _h,
            body: jsonEncode({'phone': phone, 'otp': otp, 'role': role}),
          )
          .timeout(const Duration(seconds: 8));
      final data = _check(res);
      final r = AuthResult.fromJson(data);
      // ← احفظ بـ driver_token مو access_token
      await _storage.write(key: 'driver_token', value: r.accessToken);
      return r;
    } on SocketException {
      throw 'لا يوجد اتصال';
    } on TimeoutException {
      throw 'انتهت مهلة الاتصال';
    }
  }

  Future<void> updateStatus(String token, bool online) async {
    try {
      final res = await http
          .patch(
            Uri.parse('${Api.base}${Api.driverStatus}'),
            headers: _auth(token),
            body: jsonEncode({'isAvailable': online}),
          )
          .timeout(const Duration(seconds: 8));

      _check(res);
    } on SocketException {
      throw 'لا يوجد اتصال';
    } on TimeoutException {
      throw 'انتهت مهلة الاتصال';
    }
  }

  Future<DriverModel> getMe(String token) async {
    final res = await http
        .get(Uri.parse('${Api.base}${Api.driversMe}'), headers: _auth(token))
        .timeout(const Duration(seconds: 8));
    return DriverModel.fromJson(_check(res));
  }

  Future<void> updateDriver(String token, Map<String, dynamic> data) async {
    final res = await http
        .patch(
          Uri.parse('${Api.base}${Api.driversMe}'),
          headers: _auth(token),
          body: jsonEncode(data),
        )
        .timeout(const Duration(seconds: 8));
    _check(res);
  }

  Future<void> submitApplication(String token) async {
    final res = await http
        .post(
          Uri.parse('${Api.base}${Api.submitApplication}'),
          headers: _auth(token),
        )
        .timeout(const Duration(seconds: 8));
    _check(res);
  }

  Future<String?> getToken() =>
      _storage.read(key: 'driver_token'); // ← driver_token
  Future<bool> isLoggedIn() async => (await getToken()) != null;
  Future<void> logout() => _storage.delete(key: 'driver_token');

  Map<String, dynamic> _check(http.Response res) {
    final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    if (res.statusCode >= 200 && res.statusCode < 300) return data;
    final msg = data['message'];
    throw msg is List ? msg.join(', ') : msg?.toString() ?? 'Error';
  }
}
