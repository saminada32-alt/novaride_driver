import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../../core/constants/api_constants.dart';
import '../model/car_info_model.dart';

class CarService {
  //static const String _base = 'http://127.0.0.1:3000';

  Future<void> sendCarInfo(Map<String, dynamic> body, String token) async {
    // ─── Map vehicleType للباك اند ────────────────────────────
    final typeMap = {
      'car': 'car',
      'motorcycle': 'motorcycle',
      'bike': 'bike',
      'scooter': 'scooter',
      'van': 'van',
      'wheelchair_accessible': 'wheelchair_accessible',
    };

    final payload = {
      'type': typeMap[body['type']] ?? body['type'],
      'plateNumber': body['plateNumber'],
      'brand': body['brand'],
      'model': body['model'],
      'color': body['color'],
      if (body['manufactureYear'] != null)
        'manufactureYear': body['manufactureYear'],
      if (body['passengerCount'] != null)
        'passengerCount': body['passengerCount'],
      if (body['engineSize'] != null) 'engineSize': body['engineSize'],
    };

    final res = await http
        .post(
          Uri.parse('${Api.base}${Api.vehiclesMe}'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 15));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      final msg = data['message'];
      throw Exception(msg is List ? msg.join(', ') : msg?.toString() ?? 'خطأ');
    }
  }
}
