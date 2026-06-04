import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class WorkZone {
  final int id;
  final String city;
  final String workArea;
  final String? address;
  final String workStart;
  final String workEnd;
  final bool isPrimary;

  WorkZone({
    required this.id,
    required this.city,
    required this.workArea,
    this.address,
    required this.workStart,
    required this.workEnd,
    required this.isPrimary,
  });

  factory WorkZone.fromJson(Map<String, dynamic> j) => WorkZone(
    id: j['id'] as int,
    city: j['city']?.toString() ?? '',
    workArea: j['workArea']?.toString() ?? '',
    address: j['address']?.toString(),
    workStart: j['workStart']?.toString() ?? '08:00',
    workEnd: j['workEnd']?.toString() ?? '22:00',
    isPrimary: j['isPrimary'] == true,
  );
}

class WorkZonesService {
  WorkZonesService._();
  static WorkZonesService instance = WorkZonesService._();

  static const _storage = FlutterSecureStorage();

  Future<String?> _token() => _storage.read(key: 'driver_token');
  Map<String, String> _auth(String t) => {
    'Authorization': 'Bearer $t',
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  Future<List<WorkZone>> list() async {
    final tok = await _token();
    if (tok == null) return [];

    final res = await http
        .get(Uri.parse('${Api.base}${Api.workZones}'), headers: _auth(tok))
        .timeout(const Duration(seconds: 12));

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      if (data is List) {
        return data
            .map((e) => WorkZone.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
    }
    return [];
  }

  Future<bool> isOnShift() async {
    final tok = await _token();
    if (tok == null) return true;

    final res = await http
        .get(Uri.parse('${Api.base}${Api.onShift}'), headers: _auth(tok))
        .timeout(const Duration(seconds: 8));

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      return data['onShift'] == true;
    }
    return true;
  }

  Future<void> add(Map<String, dynamic> body) async {
    final tok = await _token();
    if (tok == null) throw Exception('Not authenticated');

    final res = await http
        .post(
          Uri.parse('${Api.base}${Api.workZones}'),
          headers: _auth(tok),
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 12));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Failed to add work zone');
    }
  }

  Future<void> update(int id, Map<String, dynamic> body) async {
    final tok = await _token();
    if (tok == null) throw Exception('Not authenticated');

    final res = await http
        .patch(
          Uri.parse('${Api.base}${Api.workZones}/$id'),
          headers: _auth(tok),
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 12));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Failed to update work zone');
    }
  }

  Future<void> delete(int id) async {
    final tok = await _token();
    if (tok == null) throw Exception('Not authenticated');

    final res = await http
        .delete(
          Uri.parse('${Api.base}${Api.workZones}/$id'),
          headers: _auth(tok),
        )
        .timeout(const Duration(seconds: 12));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Failed to delete work zone');
    }
  }
}
