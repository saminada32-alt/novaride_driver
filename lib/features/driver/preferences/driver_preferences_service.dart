import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';

class DriverPreferencesService {
  DriverPreferencesService._();
  static final instance = DriverPreferencesService._();

  static const _storage = FlutterSecureStorage();
  static const _h = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<String?> _token() => _storage.read(key: 'driver_token');
  Map<String, String> _auth(String t) => {..._h, 'Authorization': 'Bearer $t'};

  Map<String, dynamic> _parse(http.Response res) {
    final data = jsonDecode(utf8.decode(res.bodyBytes));
    if (res.statusCode >= 200 && res.statusCode < 300) return data;
    final msg = data['message'];
    throw Exception(msg is List ? msg.join(', ') : msg?.toString() ?? 'Error');
  }

  Future<Map<String, dynamic>> getPreferences() async {
    final tok = await _token();
    if (tok == null) throw Exception('Not authenticated');

    final res = await http
        .get(
          Uri.parse('${Api.base}${Api.driverPreferences}'),
          headers: _auth(tok),
        )
        .timeout(const Duration(seconds: 10));

    return _parse(res);
  }

  Future<Map<String, dynamic>> setDestinationFilter({
    bool? enabled,
    double? lat,
    double? lng,
    double? radiusKm,
    String? address,
  }) async {
    final tok = await _token();
    if (tok == null) throw Exception('Not authenticated');

    final res = await http
        .patch(
          Uri.parse('${Api.base}${Api.driverDestinationFilter}'),
          headers: _auth(tok),
          body: jsonEncode({
            'enabled': ?enabled,
            'lat': ?lat,
            'lng': ?lng,
            'radiusKm': ?radiusKm,
            'address': ?address,
          }),
        )
        .timeout(const Duration(seconds: 10));

    return _parse(res);
  }

  Future<Map<String, dynamic>> setAutoAccept({
    bool? enabled,
    double? maxPickupKm,
    double? minFare,
  }) async {
    final tok = await _token();
    if (tok == null) throw Exception('Not authenticated');

    final res = await http
        .patch(
          Uri.parse('${Api.base}${Api.driverAutoAccept}'),
          headers: _auth(tok),
          body: jsonEncode({
            'enabled': ?enabled,
            'maxPickupKm': ?maxPickupKm,
            'minFare': ?minFare,
          }),
        )
        .timeout(const Duration(seconds: 10));

    return _parse(res);
  }
}
