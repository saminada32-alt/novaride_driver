import 'dart:io';
import 'package:flutter/material.dart';
import '../services/document_service.dart';

class DocumentsProvider extends ChangeNotifier {
  final DocumentsService _s = DocumentsService();
  bool isLoading = false;
  String? errorMessage;
  double uploadProgress = 0;
  Map<String, String> rejectedFields = {};
  Map<String, String> serverUrls = {};
  bool resubmitMode = false;

  final Map<String, File?> files = {
    'profile': null,
    'driverIdFront': null,
    'driverIdBack': null,
    'licenseFront': null,
    'insuranceFront': null,
    'licenseBack': null,
    'vehicleFront': null,
    'vehicleBack': null,
  };

  bool get hasRejectedFields => rejectedFields.isNotEmpty;

  List<String> get rejectedAppKeys => rejectedFields.keys
      .map(DocumentsService.appKeyForApiField)
      .whereType<String>()
      .toList();

  bool get isAllUploaded {
    if (resubmitMode && rejectedAppKeys.isNotEmpty) {
      return rejectedAppKeys.every((k) => files[k] != null);
    }
    return !files.values.contains(null);
  }

  void setFile(String key, File? file) {
    files[key] = file;
    notifyListeners();
  }

  void removeFile(String key) {
    files[key] = null;
    notifyListeners();
  }

  Future<void> loadRejectedFields(String token) async {
    try {
      final doc = await _s.fetchMyDocuments(token);
      _applyServerDocument(doc);
      notifyListeners();
    } catch (e) {
      debugPrint('loadRejectedFields: $e');
    }
  }

  Future<void> loadServerDocuments(String token) async {
    try {
      final doc = await _s.fetchMyDocuments(token);
      _applyServerDocument(doc);
      notifyListeners();
    } catch (e) {
      debugPrint('loadServerDocuments: $e');
    }
  }

  void _applyServerDocument(Map<String, dynamic>? doc) {
    serverUrls = {};
    if (doc == null) {
      rejectedFields = {};
      resubmitMode = false;
      return;
    }

    for (final entry in DocumentsService.fieldMap.entries) {
      final apiVal = doc[entry.value]?.toString();
      if (apiVal != null &&
          apiVal.isNotEmpty &&
          apiVal != 'null' &&
          apiVal != 'undefined') {
        serverUrls[entry.key] = apiVal;
      }
    }

    final raw = doc['rejectedFields'];
    if (raw is Map) {
      rejectedFields = raw.map(
        (k, v) => MapEntry(k.toString(), v?.toString() ?? ''),
      );
    } else {
      rejectedFields = {};
    }
    resubmitMode = rejectedFields.isNotEmpty;
  }

  void beginResubmit(Map<String, String> fields) {
    rejectedFields = fields;
    resubmitMode = true;
    for (final key in files.keys) {
      files[key] = null;
    }
    notifyListeners();
  }

  Future<bool> uploadAll(String token) async {
    isLoading = true;
    errorMessage = null;
    uploadProgress = 0;
    notifyListeners();
    try {
      final toUpload = <String, File?>{};
      if (resubmitMode && rejectedAppKeys.isNotEmpty) {
        for (final key in rejectedAppKeys) {
          toUpload[key] = files[key];
        }
      } else {
        toUpload.addAll(files);
      }

      await _s.uploadDocuments(
        toUpload,
        token,
        onProgress: (p) {
          uploadProgress = p;
          notifyListeners();
        },
      );

      if (resubmitMode) {
        rejectedFields = {};
        resubmitMode = false;
      }
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
