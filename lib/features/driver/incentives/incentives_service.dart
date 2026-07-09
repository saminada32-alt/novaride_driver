import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';

class DriverIncentiveZone {
  final String zoneCode;
  final String labelAr;
  final String labelEn;
  final double surgeMultiplier;
  final List<Map<String, dynamic>> incentives;

  DriverIncentiveZone({
    required this.zoneCode,
    required this.labelAr,
    required this.labelEn,
    required this.surgeMultiplier,
    required this.incentives,
  });

  factory DriverIncentiveZone.fromJson(Map<String, dynamic> j) =>
      DriverIncentiveZone(
        zoneCode: j['zoneCode']?.toString() ?? '',
        labelAr: j['labelAr']?.toString() ?? '',
        labelEn: j['labelEn']?.toString() ?? '',
        surgeMultiplier: double.tryParse(
              j['surgeMultiplier']?.toString() ?? '1',
            ) ??
            1,
        incentives: (j['incentives'] as List<dynamic>? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList(),
      );
}

class DriverIncentivesService {
  DriverIncentivesService._();
  static DriverIncentivesService instance = DriverIncentivesService._();

  static const _storage = FlutterSecureStorage();

  Future<List<DriverIncentiveZone>> fetchActive() async {
    final tok = await _storage.read(key: 'driver_token');
    final headers = <String, String>{
      'Accept': 'application/json',
      if (tok != null) 'Authorization': 'Bearer $tok',
    };

    final res = await http
        .get(Uri.parse('${Api.base}${Api.incentivesActive}'), headers: headers)
        .timeout(const Duration(seconds: 15));

    if (res.statusCode < 200 || res.statusCode >= 300) return [];

    final data = jsonDecode(utf8.decode(res.bodyBytes));
    final list = data is List ? data : (data['zones'] as List<dynamic>? ?? []);
    return list
        .map((e) => DriverIncentiveZone.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
