import 'dart:convert';
import '../../../../../core/constants/api_constants.dart';
import 'package:http/http.dart' as http;

class DriverService {
  //static const String _base = 'http://127.0.0.1:3000';

  static const _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<void> updatePersonalInfo(
    Map<String, dynamic> data,
    String token,
  ) async {
    final res = await http
        .patch(
          Uri.parse('${Api.base}${Api.driversMe}'),
          headers: {..._headers, 'Authorization': 'Bearer $token'},
          body: jsonEncode(data),
        )
        .timeout(const Duration(seconds: 15));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      final body = jsonDecode(utf8.decode(res.bodyBytes));
      final msg = body['message'];
      throw Exception(msg is List ? msg.join(', ') : msg?.toString() ?? 'خطأ');
    }
  }
}
