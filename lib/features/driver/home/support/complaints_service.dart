import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';

class DriverComplaintsService {
  DriverComplaintsService._();
  static final instance = DriverComplaintsService._();

  static const _storage = FlutterSecureStorage();

  Future<void> submit({
    required String type,
    required String description,
    int? rideId,
  }) async {
    final token = await _storage.read(key: 'driver_token');
    if (token == null) throw Exception('Not authenticated');

    final body = <String, dynamic>{
      'type': type,
      'description': description.trim(),
    };
    if (rideId != null) body['rideId'] = rideId;

    final res = await http
        .post(
          Uri.parse('${Api.base}/complaints'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 12));

    if (res.statusCode != 201 && res.statusCode != 200) {
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      final msg = data['message'];
      throw Exception(
        msg is List ? msg.join(', ') : msg?.toString() ?? 'Error',
      );
    }
  }
}
