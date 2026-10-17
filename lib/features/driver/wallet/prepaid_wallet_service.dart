import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';

class DriverPrepaidWalletService {
  DriverPrepaidWalletService._();
  static final instance = DriverPrepaidWalletService._();

  static const _storage = FlutterSecureStorage();
  static const _timeout = Duration(seconds: 12);

  Future<String?> _token() => _storage.read(key: 'driver_token');

  Map<String, String> _headers(String tok) => {
        'Authorization': 'Bearer $tok',
        'Accept': 'application/json',
      };

  Future<Map<String, dynamic>?> getBalance() async {
    try {
      final tok = await _token();
      if (tok == null) return null;

      final res = await http
          .get(Uri.parse('${Api.base}/wallet/me'), headers: _headers(tok))
          .timeout(_timeout);

      if (res.statusCode == 200 && res.body.isNotEmpty) {
        return Map<String, dynamic>.from(
          jsonDecode(utf8.decode(res.bodyBytes)) as Map,
        );
      }
    } catch (e) {
      debugPrint('getBalance error: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> getTopupInstructions() async {
    try {
      final tok = await _token();
      if (tok == null) return null;

      final res = await http
          .get(
            Uri.parse('${Api.base}/wallet/me/topup-instructions'),
            headers: _headers(tok),
          )
          .timeout(_timeout);

      if (res.statusCode == 200 && res.body.isNotEmpty) {
        return Map<String, dynamic>.from(
          jsonDecode(utf8.decode(res.bodyBytes)) as Map,
        );
      }
    } catch (e) {
      debugPrint('getTopupInstructions error: $e');
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getMyTopupRequests() async {
    try {
      final tok = await _token();
      if (tok == null) return [];

      final res = await http
          .get(
            Uri.parse('${Api.base}/wallet/me/topup-requests'),
            headers: _headers(tok),
          )
          .timeout(_timeout);

      if (res.statusCode == 200 && res.body.isNotEmpty) {
        final body = jsonDecode(utf8.decode(res.bodyBytes));
        if (body is List) return body.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint('getMyTopupRequests error: $e');
    }
    return [];
  }

  /// Multipart so a transfer-receipt image can ride along with the fields.
  /// Slow networks get a long timeout — a phone screenshot is a few hundred KB.
  Future<TopupSubmitResult> submitTopupRequest({
    required double amount,
    required String method,
    String? reference,
    String? note,
    File? receipt,
  }) async {
    try {
      final tok = await _token();
      if (tok == null) return const TopupSubmitResult(ok: false);

      final req = http.MultipartRequest(
        'POST',
        Uri.parse('${Api.base}/wallet/me/topup-requests'),
      )
        ..headers.addAll(_headers(tok))
        ..fields['amount'] = amount.toStringAsFixed(0)
        ..fields['method'] = method;
      if (reference != null && reference.isNotEmpty) {
        req.fields['reference'] = reference;
      }
      if (note != null && note.isNotEmpty) req.fields['note'] = note;
      if (receipt != null) {
        req.files.add(await http.MultipartFile.fromPath('receipt', receipt.path));
      }

      final streamed = await req.send().timeout(const Duration(seconds: 90));
      final res = await http.Response.fromStream(streamed);
      if (res.statusCode == 201 || res.statusCode == 200) {
        return const TopupSubmitResult(ok: true);
      }

      String? message;
      try {
        final body = jsonDecode(utf8.decode(res.bodyBytes));
        if (body is Map) message = body['message']?.toString();
      } catch (_) {}
      return TopupSubmitResult(ok: false, message: message);
    } catch (e) {
      debugPrint('submitTopupRequest error: $e');
      return const TopupSubmitResult(ok: false);
    }
  }
}

class TopupSubmitResult {
  final bool ok;
  final String? message;
  const TopupSubmitResult({required this.ok, this.message});

  bool get isDuplicateReceipt =>
      (message ?? '').toLowerCase().contains('already submitted');
}
