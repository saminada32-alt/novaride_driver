import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class DriverBalanceService {
  DriverBalanceService._();
  static DriverBalanceService instance = DriverBalanceService._();

  static const _storage = FlutterSecureStorage();

  Future<String?> _token() => _storage.read(key: 'driver_token');
  Map<String, String> _auth(String t) => {
    'Authorization': 'Bearer $t',
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  Future<double> getBalance() async {
    final tok = await _token();
    if (tok == null) return 0;

    final res = await http
        .get(Uri.parse('${Api.base}${Api.balanceMe}'), headers: _auth(tok))
        .timeout(const Duration(seconds: 12));

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      return double.tryParse(data['balance']?.toString() ?? '0') ?? 0;
    }
    return 0;
  }

  Future<List<Map<String, dynamic>>> getPayouts() async {
    final tok = await _token();
    if (tok == null) return [];

    final res = await http
        .get(
          Uri.parse('${Api.base}${Api.balancePayouts}'),
          headers: _auth(tok),
        )
        .timeout(const Duration(seconds: 12));

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      if (data is List) {
        return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    }
    return [];
  }

  Future<void> requestPayout(double amount) async {
    final tok = await _token();
    if (tok == null) throw Exception('Not authenticated');

    final res = await http
        .post(
          Uri.parse('${Api.base}${Api.balancePayout}'),
          headers: _auth(tok),
          body: jsonEncode({'amount': amount}),
        )
        .timeout(const Duration(seconds: 15));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      final msg = data['message'];
      throw Exception(msg is List ? msg.join(', ') : msg?.toString() ?? 'Error');
    }
  }
}
