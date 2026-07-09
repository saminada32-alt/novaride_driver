import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/location_model.dart';
import '../../../../../core/constants/api_constants.dart';

class LocationService {
  static const _h = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<bool> submitLocation(LocationModel loc, String token) async {
    final res = await http
        .post(
          Uri.parse('${Api.base}${Api.workArea}'),
          headers: {..._h, 'Authorization': 'Bearer $token'},
          body: jsonEncode(loc.toJson()),
        )
        .timeout(const Duration(seconds: 15));

    if (res.statusCode >= 200 && res.statusCode < 300) return true;

    throw Exception(_errorFromResponse(res));
  }

  String _errorFromResponse(http.Response res) {
    try {
      final body = jsonDecode(res.body);
      if (body is Map<String, dynamic>) {
        final message = body['message'];
        if (message is List) return message.join('\n');
        if (message is String && message.isNotEmpty) return message;
      }
    } catch (_) {}
    return 'Request failed (${res.statusCode})';
  }
}
