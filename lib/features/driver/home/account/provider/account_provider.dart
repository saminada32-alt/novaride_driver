import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../onboarding/documents/services/document_service.dart';
import '../model/account_model.dart';
import '../service/account_service.dart';
import '../../../../auth/models/auth_model.dart';
import '../../../../auth/providers/auth_provider.dart';
import '../../../../auth/welcome/welcome_screen.dart';

class AccountProvider extends ChangeNotifier {
  final AccountService _service = AccountService();

  AccountModel? _account;
  String? _localProfilePreview;
  bool _loading = false;
  bool isSaving = false;
  String? _error;

  AccountModel? get account => _account;
  String? get localProfilePreview => _localProfilePreview;
  bool get isLoading => _loading;
  String? get error => _error;

  /// Instant home shell from splash auth — full profile loads in background.
  void seedFromDriver(DriverModel driver) {
    if (_account != null) return;
    _account = AccountModel(
      id: driver.id.toString(),
      phone: driver.phone,
      name: driver.fullName,
      email: driver.email ?? '',
      profileImage: '',
      isVerified: driver.isApproved,
      totalTrips: 0,
      rating: driver.rating,
      acceptedTrips: 0,
      cancelledTrips: 0,
    );
    notifyListeners();
  }

  Future<void> loadAccount(String token) async {
    if (_loading) return;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _account = await _service.fetchAccount(token);
    } catch (e) {
      _error = e.toString();
      debugPrint('AccountProvider error: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> updateAccount({
    required String token,
    required String name,
    required String email,
    required String phone,
  }) async {
    isSaving = true;
    notifyListeners();
    try {
      final parts = name.trim().split(' ');
      await _service.updateAccount(
        token,
        firstName: parts.isNotEmpty ? parts.first : null,
        lastName: parts.length > 1 ? parts.sublist(1).join(' ') : null,
        email: email.isNotEmpty ? email : null,
      );
      _account = _account?.copyWith(name: name, email: email, phone: phone);
      isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      isSaving = false;
      notifyListeners();
      return false;
    }
  }

  void clearLocalProfilePreview() {
    if (_localProfilePreview == null) return;
    _localProfilePreview = null;
    notifyListeners();
  }

  Future<void> uploadProfileImage(String token, File file) async {
    if (_account == null) return;

    isSaving = true;
    _error = null;
    _localProfilePreview = file.path;
    _account = _account!.copyWith(profileImage: file.path);
    notifyListeners();

    try {
      final url = await DocumentsService().uploadDriverPhoto(file, token);
      _account = _account!.copyWith(profileImage: url);
    } catch (e) {
      _error = e.toString();
      debugPrint('Profile upload error: $e');
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<void> logout(BuildContext context) async {
    _account = null;
    notifyListeners();
    await context.read<AuthProvider>().logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (_) => false,
    );
  }
}
