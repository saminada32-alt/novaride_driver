import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/utils/auth_errors.dart';
import '../models/auth_model.dart';
import '../services/auth_service.dart';

enum DriverStatus { notLoggedIn, pending, approved, rejected }

class AuthProvider extends ChangeNotifier {
  DriverModel? _driver;
  String? _token;
  bool _isNew = false;
  String? _error;
  bool _load = false;

  DriverModel? get driver => _driver;
  String? get token => _token;
  bool get isNew => _isNew;
  String? get error => _error;
  bool get isAccountNotFound => isAccountNotFoundError(_error);

  // ───────────────────────────────────────────────
  // CHECK DRIVER STATUS
  // ───────────────────────────────────────────────
  Future<DriverStatus> checkDriverStatus() async {
    try {
      final tok = await AuthService.instance.getToken();
      if (tok == null) return DriverStatus.notLoggedIn;

      _token = tok;
      _driver = await AuthService.instance.getMe(tok);
      notifyListeners();

      if (_driver!.isApproved) return DriverStatus.approved;
      if (_driver!.isRejected) return DriverStatus.rejected;
      return DriverStatus.pending;
    } catch (_) {
      return DriverStatus.notLoggedIn;
    }
  }

  bool _sendingOtp = false;
  bool _verifying = false;

  bool get sendingOtp => _sendingOtp;
  bool get verifying => _verifying;
  bool get loading => _verifying;

  // ───────────────────────────────────────────────
  // SEND OTP
  // ───────────────────────────────────────────────
  Future<bool> sendLoginOtp(String phone, {String role = 'DRIVER'}) =>
      sendOtp(phone, role: role, forLogin: true);

  Future<bool> sendOtp(String phone, {String role = 'DRIVER', bool forLogin = false}) async {
    if (_sendingOtp) return false;
    _sendingOtp = true;
    _error = null;
    notifyListeners();
    try {
      await AuthService.instance.sendOtp(phone, role: role, forLogin: forLogin);
      _sendingOtp = false;
      notifyListeners();
      return true;
    } catch (e) {
      _sendingOtp = false;
      _error = _mapError(e);
      notifyListeners();
      return false;
    }
  }

  String _mapError(Object e) {
    final raw = e.toString().replaceAll('Exception: ', '');
    if (e is TimeoutException ||
        raw.toLowerCase().contains('timeout') ||
        raw.contains('مهلة')) {
      return 'الشبكة بطيئة — حاول مجدداً';
    }
    return raw;
  }

  // ───────────────────────────────────────────────
  // VERIFY OTP
  // ───────────────────────────────────────────────
  Future<bool> verifyOtp(
    String phone,
    String otp, {
    String role = 'DRIVER',
    List<Map<String, String>>? consents,
  }) async {
    _verifying = true;
    _error = null;
    notifyListeners();
    try {
      final r = await AuthService.instance.verifyOtp(
        phone,
        otp,
        role: role,
        consents: consents,
      );

      _driver = r.driver;
      _token = r.accessToken;
      _isNew = r.isNew;

      _verifying = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _mapError(e);
      _verifying = false;
      notifyListeners();
      return false;
    }
  }

  // ───────────────────────────────────────────────
  // UPDATE DRIVER INFO
  // ───────────────────────────────────────────────
  Future<bool> updateInfo(Map<String, dynamic> data) async {
    if (_token == null) return false;

    try {
      await AuthService.instance.updateDriver(_token!, data);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ───────────────────────────────────────────────
  // UPDATE ONLINE STATUS
  // ───────────────────────────────────────────────
  Future<void> updateOnlineStatus(bool online) async {
    if (_token == null) return;

    try {
      await AuthService.instance.updateStatus(_token!, online);
    } catch (_) {}
  }

  // ───────────────────────────────────────────────
  // SUBMIT APPLICATION
  // ───────────────────────────────────────────────
  Future<bool> submitApplication() async {
    if (_token == null) return false;

    try {
      await AuthService.instance.submitApplication(_token!);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ───────────────────────────────────────────────
  // LOGOUT
  // ───────────────────────────────────────────────
  Future<void> logout() async {
    await AuthService.instance.logout();
    _driver = null;
    _token = null;
    notifyListeners();
  }

  // ───────────────────────────────────────────────
  // INTERNAL HELPERS
  // ───────────────────────────────────────────────
  void _begin() {
    _load = true;
    _error = null;
    notifyListeners();
  }

  void _fail(String e) {
    _error = e;
    _load = false;
    notifyListeners();
  }
}
