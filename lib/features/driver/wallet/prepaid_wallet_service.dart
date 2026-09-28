import 'dart:convert';
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

  Future<bool> submitTopupRequest({
    required double amount,
    required String method,
    String? reference,
    String? note,
  }) async {
    try {
      final tok = await _token();
      if (tok == null) return false;

      final res = await http
          .post(
            Uri.parse('${Api.base}/wallet/me/topup-requests'),
            headers: {
              ..._headers(tok),
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'amount': amount,
              'method': method,
              if (reference != null && reference.isNotEmpty)
                'reference': reference,
              if (note != null && note.isNotEmpty) 'note': note,
            }),
          )
          .timeout(_timeout);

      return res.statusCode == 201 || res.statusCode == 200;
    } catch (e) {
      debugPrint('submitTopupRequest error: $e');
      return false;
    }
  }
}
