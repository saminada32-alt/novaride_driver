import 'package:flutter/material.dart';
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
  bool get loading => _load;

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

  // ───────────────────────────────────────────────
  // SEND OTP
  // ───────────────────────────────────────────────
  bool _sendingOtp = false;
  Future<bool> sendOtp(String phone, {String role = 'DRIVER'}) async {
    if (_sendingOtp) return false; // لمنع الطلبات المتكررة
    _sendingOtp = true;
    _begin();
    try {
      await AuthService.instance.sendOtp(phone, role: role);
      _load = false;
      _sendingOtp = false;
      notifyListeners();
      return true;
    } catch (e) {
      _sendingOtp = false;
      _fail(e.toString());
      return false;
    }
  }

  // ───────────────────────────────────────────────
  // VERIFY OTP
  // ───────────────────────────────────────────────
  Future<bool> verifyOtp(
    String phone,
    String otp, {
    String role = 'DRIVER',
  }) async {
    _begin();
    try {
      final r = await AuthService.instance.verifyOtp(phone, otp, role: role);

      _driver = r.driver;
      _token = r.accessToken;
      _isNew = r.isNew;

      _load = false;
      notifyListeners();
      return true;
    } catch (e) {
      _fail(e.toString());
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
