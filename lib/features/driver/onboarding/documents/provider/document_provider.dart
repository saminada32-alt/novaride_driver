import 'dart:io';
import 'package:flutter/material.dart';
import '../services/document_service.dart';

class DocumentsProvider extends ChangeNotifier {
  final DocumentsService _s = DocumentsService();
  bool isLoading = false;
  String? errorMessage;
  double uploadProgress = 0;

  final Map<String, File?> files = {
    'profile': null,
    'driverIdFront': null,
    'driverIdBack': null,
    'licenseFront': null,
    'licenseBack': null,
    'vehicleFront': null,
    'vehicleBack': null,
  };

  bool get isAllUploaded => !files.values.contains(null);

  void setFile(String key, File? file) {
    files[key] = file;
    notifyListeners();
  }

  void removeFile(String key) {
    files[key] = null;
    notifyListeners();
  }

  Future<bool> uploadAll(String token) async {
    isLoading = true;
    errorMessage = null;
    uploadProgress = 0;
    notifyListeners();
    try {
      await _s.uploadDocuments(
        files,
        token,
        onProgress: (p) {
          uploadProgress = p;
          notifyListeners();
        },
      );
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
