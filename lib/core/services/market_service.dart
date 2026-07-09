import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class MarketInfo {
  final String code;
  final String currencySymbol;

  const MarketInfo({required this.code, required this.currencySymbol});

  factory MarketInfo.fromJson(Map<String, dynamic> j) => MarketInfo(
    code: j['code']?.toString() ?? 'syria',
    currencySymbol: j['currencySymbol']?.toString() ?? 'ل.س',
  );
}

class MarketService {
  MarketService._();
  static final MarketService instance = MarketService._();

  MarketInfo? _cached;

  Future<MarketInfo> resolve(double lat, double lng) async {
    try {
      final res = await http
          .get(Uri.parse('${Api.base}/markets/resolve?lat=$lat&lng=$lng'))
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        _cached = MarketInfo.fromJson(Map<String, dynamic>.from(data));
        return _cached!;
      }
    } catch (_) {}
    return _cached ?? const MarketInfo(code: 'syria', currencySymbol: 'ل.س');
  }

  String? get cachedCode => _cached?.code;
}
