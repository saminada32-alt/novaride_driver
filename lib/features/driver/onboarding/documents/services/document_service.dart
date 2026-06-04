import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import '../../../../../core/constants/api_constants.dart';

class DocumentsService {
  // ─── أسماء الحقول تطابق الباك اند بالضبط ─────────────────
  static const Map<String, String> _fieldMap = {
    'profile': 'driverPhoto',
    'driverIdFront': 'idFront',
    'driverIdBack': 'idBack',
    'licenseFront': 'licenseFront',
    'licenseBack': 'licenseBack',
    'vehicleFront': 'vehicleFront',
    'vehicleBack': 'vehicleBack',
  };

  Future<void> uploadDocuments(
    Map<String, File?> files,
    String token, {
    void Function(double progress)? onProgress,
  }) async {
    final uri = Uri.parse('${Api.base}${Api.uploadDoc}');

    // ─── بناء multipart request ───────────────────────────────
    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

    int count = 0;

    for (final entry in files.entries) {
      final file = entry.value;
      final fieldName = _fieldMap[entry.key] ?? entry.key;

      if (file == null) {
        debugPrint('⚠️ Skip ${entry.key}: null');
        continue;
      }
      if (!file.existsSync()) {
        debugPrint('⚠️ Skip ${entry.key}: file not found at ${file.path}');
        continue;
      }
      final size = await file.length();
      if (size == 0) {
        debugPrint('⚠️ Skip ${entry.key}: empty file');
        continue;
      }

      // اختر mime type حسب الامتداد
      final ext = path.extension(file.path).toLowerCase();
      final mimeType = ext == '.png'
          ? 'image/png'
          : ext == '.jpg' || ext == '.jpeg'
          ? 'image/jpeg'
          : ext == '.webp'
          ? 'image/webp'
          : 'image/jpeg';

      request.files.add(
        await http.MultipartFile.fromPath(
          fieldName,
          file.path,
          // لا تحدد filename — اتركه تلقائي
        ),
      );

      count++;
      debugPrint('✅ Added $fieldName from ${file.path} ($size bytes)');
    }

    if (count == 0) {
      throw Exception('لم يتم اختيار أي ملفات صالحة للرفع');
    }

    onProgress?.call(0.1);
    debugPrint('📤 Uploading $count files to ${uri.toString()}');

    // ─── أرسل ─────────────────────────────────────────────────
    final streamed = await request.send().timeout(const Duration(seconds: 120));

    onProgress?.call(0.8);

    final responseBody = await streamed.stream.bytesToString();
    onProgress?.call(1.0);

    debugPrint('📥 Response ${streamed.statusCode}: $responseBody');

    if (streamed.statusCode >= 200 && streamed.statusCode < 300) {
      debugPrint('✅ Upload successful');
      return;
    }

    // ─── تحليل الخطأ ──────────────────────────────────────────
    String errMsg = 'فشل الرفع (${streamed.statusCode})';
    try {
      final j = jsonDecode(responseBody) as Map<String, dynamic>;
      final m = j['message'];
      errMsg = m is List ? m.join(', ') : m?.toString() ?? errMsg;
    } catch (_) {
      if (responseBody.isNotEmpty) errMsg = responseBody;
    }

    throw Exception(errMsg);
  }

  /// رفع صورة السائق الشخصية فقط (sidebar / account)
  Future<String> uploadDriverPhoto(File file, String token) async {
    if (!file.existsSync()) {
      throw Exception('File not found');
    }

    final uri = Uri.parse('${Api.base}${Api.uploadDoc}');
    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      })
      ..files.add(
        await http.MultipartFile.fromPath('driverPhoto', file.path),
      );

    final streamed = await request.send().timeout(const Duration(seconds: 60));
    final responseBody = await streamed.stream.bytesToString();

    if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
      throw Exception('Upload failed (${streamed.statusCode})');
    }

    final j = jsonDecode(responseBody) as Map<String, dynamic>;
    final photo = j['driverPhoto']?.toString();
    if (photo == null || photo.isEmpty) {
      throw Exception('No profile URL returned');
    }
    return photo;
  }
}
