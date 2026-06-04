import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/account_model.dart';
import '../../../../../core/constants/api_constants.dart';

class AccountService {
  static const _h = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<AccountModel> fetchAccount(String token) async {
    final res = await http
        .get(
          Uri.parse('${Api.base}${Api.driversMe}'),
          headers: {..._h, 'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) throw Exception('Failed to load account');

    final raw = jsonDecode(utf8.decode(res.bodyBytes));
    // الباك اند ممكن يرجع nested أو flat
    final j = raw is Map<String, dynamic> ? raw : raw['driver'] ?? raw;
    return AccountModel.fromJson(j as Map<String, dynamic>);
  }

  Future<void> updateAccount(
    String token, {
    String? firstName,
    String? lastName,
    String? email,
  }) async {
    final body = <String, dynamic>{};
    if (firstName != null) body['firstName'] = firstName;
    if (lastName != null) body['lastName'] = lastName;
    if (email != null) body['email'] = email;

    if (body.isEmpty) return;

    final res = await http
        .patch(
          Uri.parse('${Api.base}${Api.driversMe}'),
          headers: {..._h, 'Authorization': 'Bearer $token'},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Failed to update');
    }
  }
}
