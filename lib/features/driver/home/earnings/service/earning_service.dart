import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../model/earning_model.dart';
import '../../../../../core/constants/api_constants.dart';

class EarningService {
  static const _h = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<EarningModel> fetchEarnings(String token) async {
    final res = await http
        .get(
          Uri.parse('${Api.base}${Api.earningsDashboard}'),
          headers: {..._h, 'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) {
      debugPrint('Earnings error: ${res.statusCode} ${res.body}');
      return _empty();
    }

    final j = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    return _parse(j);
  }

  EarningModel _parse(Map<String, dynamic> j) {
    double d(dynamic v) => double.tryParse(v?.toString() ?? '0') ?? 0.0;

    List<DailyEarning> list(dynamic v) {
      if (v is! List) return [];
      return v.map((e) {
        return DailyEarning(
          label: e['label']?.toString() ?? '',
          amount: d(e['amount']),
        );
      }).toList();
    }

    List<RecentRide> rides(dynamic v) {
      if (v is! List) return [];
      return v.map((e) => RecentRide.fromJson(e)).toList();
    }

    return EarningModel(
      total: d(j['total'] ?? j['allTime']),
      today: d(j['daily'] ?? j['today']),
      week: d(j['weekly'] ?? j['week']),
      month: d(j['monthly'] ?? j['month']),
      trips: int.tryParse(j['trips']?.toString() ?? '0') ?? 0,
      daily: list(j['dailyBreakdown'] ?? j['daily_breakdown']),
      weekly: list(j['weeklyBreakdown'] ?? j['weekly_breakdown']),
      monthly: list(j['monthlyBreakdown'] ?? j['monthly_breakdown']),
      recentRides: rides(j['recentRides'] ?? j['recent_rides']),
    );
  }

  EarningModel _empty() => const EarningModel(
        total: 0,
        today: 0,
        week: 0,
        month: 0,
        trips: 0,
        daily: [],
        weekly: [],
        monthly: [],
        recentRides: [],
      );
}
