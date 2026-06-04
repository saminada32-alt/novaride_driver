import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';

class DriverSubscriptionService {
  DriverSubscriptionService._();
  static final instance = DriverSubscriptionService._();

  static const _storage = FlutterSecureStorage();
  static const _timeout = Duration(seconds: 12);

  Future<String?> _token() => _storage.read(key: 'driver_token');

  Map<String, String> _headers(String tok) => {
        'Authorization': 'Bearer $tok',
        'Accept': 'application/json',
      };

  Future<Map<String, dynamic>?> getPlans() async {
    try {
      final res = await http
          .get(
            Uri.parse('${Api.base}/subscriptions/plans'),
            headers: const {'Accept': 'application/json'},
          )
          .timeout(_timeout);

      if (res.statusCode == 200 && res.body.isNotEmpty) {
        return Map<String, dynamic>.from(
          jsonDecode(utf8.decode(res.bodyBytes)) as Map,
        );
      }

      // fallback with auth if public route blocked
      final tok = await _token();
      if (tok != null) {
        final authed = await http
            .get(
              Uri.parse('${Api.base}/subscriptions/plans'),
              headers: _headers(tok),
            )
            .timeout(_timeout);
        if (authed.statusCode == 200 && authed.body.isNotEmpty) {
          return Map<String, dynamic>.from(
            jsonDecode(utf8.decode(authed.bodyBytes)) as Map,
          );
        }
      }
    } catch (e) {
      debugPrint('getPlans error: $e');
    }
    return defaultPlans();
  }

  static Map<String, dynamic> defaultPlans() => {
        'plans': [
          {
            'planType': 'commission',
            'commissionPercent': 10,
            'billingCycleDays': 7,
          },
          {
            'planType': 'monthly',
            'monthlyFee': 150000,
            'billingCycleDays': 30,
          },
        ],
        'currency': 'SYP',
        'currencySymbol': 'ل.س',
        'paymentInstructions': {
          'shamCashPhone': '0930000000',
          'balancePhone': '0930000000',
          'bankName': 'بنك سوريا والمهجر',
          'bankAccount': '00000000000',
          'bankIban': 'SY000000000000000000',
        },
      };

  Future<Map<String, dynamic>?> getMySubscription() async {
    try {
      final tok = await _token();
      if (tok == null) return null;

      final res = await http
          .get(
            Uri.parse('${Api.base}/subscriptions/me'),
            headers: _headers(tok),
          )
          .timeout(_timeout);

      if (res.statusCode == 200 && res.body.isNotEmpty) {
        final body = jsonDecode(utf8.decode(res.bodyBytes));
        if (body == null) return null;
        if (body is Map) return Map<String, dynamic>.from(body);
      }
    } catch (e) {
      debugPrint('getMySubscription error: $e');
    }
    return null;
  }

  Future<bool> choosePlan({
    required String planType,
    required String paymentMethod,
  }) async {
    try {
      final tok = await _token();
      if (tok == null) return false;

      final res = await http
          .post(
            Uri.parse('${Api.base}/subscriptions/choose'),
            headers: {
              ..._headers(tok),
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'planType': planType,
              'paymentMethod': paymentMethod,
            }),
          )
          .timeout(_timeout);

      return res.statusCode == 201 || res.statusCode == 200;
    } catch (e) {
      debugPrint('choosePlan error: $e');
      return false;
    }
  }

  Future<bool> submitPayment({
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
            Uri.parse('${Api.base}/subscriptions/me/submit-payment'),
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
      debugPrint('submitPayment error: $e');
      return false;
    }
  }
}
