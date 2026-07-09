import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';

class DriverReferralStats {
  final String code;
  final int totalReferrals;
  final double totalEarned;

  DriverReferralStats({
    required this.code,
    required this.totalReferrals,
    required this.totalEarned,
  });

  factory DriverReferralStats.fromJson(Map<String, dynamic> j) =>
      DriverReferralStats(
        code: j['code']?.toString() ?? '',
        totalReferrals: (j['totalReferrals'] as num?)?.toInt() ?? 0,
        totalEarned: (j['totalEarned'] as num?)?.toDouble() ?? 0,
      );
}

class DriverReferralService {
  DriverReferralService._();
  static final DriverReferralService instance = DriverReferralService._();
  static const _storage = FlutterSecureStorage();

  Future<String?> _token() => _storage.read(key: 'driver_token');

  Future<DriverReferralStats> getMyStats() async {
    final tok = await _token();
    if (tok == null) throw Exception('Not authenticated');
    final res = await http.get(
      Uri.parse('${Api.base}/referrals/me'),
      headers: {'Authorization': 'Bearer $tok'},
    );
    final data = jsonDecode(utf8.decode(res.bodyBytes));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return DriverReferralStats.fromJson(Map<String, dynamic>.from(data));
    }
    throw Exception(data['message']?.toString() ?? 'Failed');
  }
}
