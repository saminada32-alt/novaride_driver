import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../../core/utils/media_url.dart';
import '../../../onboarding/documents/services/document_service.dart';
import '../model/account_model.dart';
import '../service/account_service.dart';
import '../../../../auth/providers/auth_provider.dart';
import '../../../../auth/welcome/welcome_screen.dart';

class AccountProvider extends ChangeNotifier {
  final AccountService _service = AccountService();
  final ImagePicker _picker = ImagePicker();

  AccountModel? _account;
  bool _loading = false;
  bool isSaving = false;
  String? _error;

  AccountModel? get account => _account;
  bool get isLoading => _loading;
  String? get error => _error;

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

  Future<void> pickProfileImage(String token) async {
    final p = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (p == null || _account == null) return;

    isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final url = await DocumentsService().uploadDriverPhoto(
        File(p.path),
        token,
      );
      _account = _account!.copyWith(
        profileImage: resolveMediaUrl(url) ?? url,
      );
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
