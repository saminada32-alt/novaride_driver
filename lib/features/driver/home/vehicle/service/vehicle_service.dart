import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/vehicle_model.dart';
import '../../../../../core/constants/api_constants.dart';

class VehicleService {
  static const _base = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<VehicleModel?> fetchVehicle(String token) async {
    final res = await http
        .get(
          Uri.parse('${Api.base}${Api.vehiclesMe}'),
          headers: {..._base, 'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) return null;
    return VehicleModel.fromJson(jsonDecode(utf8.decode(res.bodyBytes)));
  }

  Future<void> updateVehicle(String token, Map<String, dynamic> data) async {
    final res = await http
        .patch(
          Uri.parse('${Api.base}${Api.vehiclesMe}'),
          headers: {..._base, 'Authorization': 'Bearer $token'},
          body: jsonEncode(data),
        )
        .timeout(const Duration(seconds: 15));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Failed to update vehicle');
    }
  }
}
