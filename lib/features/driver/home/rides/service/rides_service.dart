import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../../../../core/constants/api_constants.dart';
import '../model/ride_model.dart';

class DriverRidesService {
  DriverRidesService._();
  static DriverRidesService instance = DriverRidesService._();

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

  // ─── جيب رحلاتي كسائق ────────────────────────────────────
  Future<List<DriverRideModel>> getMyRides({String? status}) async {
    final tok = await _token();
    if (tok == null) return [];

    final uri = Uri.parse(
      '${Api.base}${Api.myRides}',
    ).replace(queryParameters: status != null ? {'status': status} : null);

    final res = await http
        .get(uri, headers: _auth(tok))
        .timeout(const Duration(seconds: 15));

    if (res.statusCode == 200) {
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      final list = data is List ? data : [];
      return list
          .map((r) => DriverRideModel.fromJson(Map<String, dynamic>.from(r)))
          .toList();
    }
    return [];
  }

  Future<List<DriverRideModel>> getScheduledRides({
    double? lat,
    double? lng,
  }) async {
    final tok = await _token();
    if (tok == null) return [];

    final params = <String, String>{};
    if (lat != null) params['lat'] = lat.toString();
    if (lng != null) params['lng'] = lng.toString();

    final uri = Uri.parse('${Api.base}${Api.myScheduledRides}')
        .replace(queryParameters: params.isEmpty ? null : params);

    final res = await http
        .get(uri, headers: _auth(tok))
        .timeout(const Duration(seconds: 15));

    if (res.statusCode == 200) {
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      final list = data is List ? data : [];
      return list
          .map((r) => DriverRideModel.fromJson(Map<String, dynamic>.from(r)))
          .toList();
    }
    return [];
  }

  Future<List<DriverRideModel>> getPendingRides({
    double? lat,
    double? lng,
  }) async {
    final tok = await _token();
    if (tok == null) return [];

    final params = <String, String>{};
    if (lat != null) params['lat'] = lat.toString();
    if (lng != null) params['lng'] = lng.toString();

    final uri = Uri.parse('${Api.base}${Api.pendingRides}')
        .replace(queryParameters: params.isEmpty ? null : params);

    final res = await http
        .get(uri, headers: _auth(tok))
        .timeout(const Duration(seconds: 15));

    if (res.statusCode == 200) {
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      final list = data is List ? data : [];
      return list
          .map((r) => DriverRideModel.fromJson(Map<String, dynamic>.from(r)))
          .toList();
    }
    return [];
  }

  Future<void> rejectRideOffer(int rideId) async {
    final tok = await _token();
    if (tok == null) throw Exception('Not authenticated');

    final res = await http
        .patch(
          Uri.parse('${Api.base}/rides/$rideId/reject-offer'),
          headers: _auth(tok),
        )
        .timeout(const Duration(seconds: 10));

    _parse(res);
  }

  // ─── قبول رحلة ───────────────────────────────────────────
  Future<DriverRideModel> acceptRide(int rideId) async {
    final tok = await _token();
    if (tok == null) throw Exception('Not authenticated');

    final res = await http
        .patch(
          Uri.parse('${Api.base}/rides/$rideId/accept'),
          headers: _auth(tok),
        )
        .timeout(const Duration(seconds: 10));

    return DriverRideModel.fromJson(_parse(res));
  }

  // ─── تحديث الحالة ────────────────────────────────────────
  Future<DriverRideModel> updateStatus(
    int rideId,
    DriverRideStatus status,
  ) async {
    final tok = await _token();
    if (tok == null) throw Exception('Not authenticated');

    // حوّل enum لـ string يطابق الباك اند
    final statusStr = status.name.toUpperCase();

    final res = await http
        .patch(
          Uri.parse('${Api.base}/rides/$rideId/status'),
          headers: _auth(tok),
          body: jsonEncode({'status': statusStr}),
        )
        .timeout(const Duration(seconds: 10));

    return DriverRideModel.fromJson(_parse(res));
  }

  // ─── إلغاء رحلة ──────────────────────────────────────────
  Future<bool> cancelRide(int rideId, {String? reason}) async {
    final tok = await _token();
    if (tok == null) return false;

    final res = await http
        .patch(
          Uri.parse('${Api.base}/rides/$rideId/cancel'),
          headers: _auth(tok),
          body: jsonEncode({'reason': reason ?? 'Cancelled by driver'}),
        )
        .timeout(const Duration(seconds: 10));

    return res.statusCode == 200;
  }

  Future<void> setPaymentMethod(
    int rideId,
    String paymentMethod, {
    String? paymentReference,
  }) async {
    final tok = await _token();
    if (tok == null) throw Exception('Not authenticated');

    final body = <String, dynamic>{'paymentMethod': paymentMethod};
    if (paymentReference != null && paymentReference.isNotEmpty) {
      body['paymentReference'] = paymentReference;
    }

    final res = await http
        .patch(
          Uri.parse('${Api.base}/rides/$rideId/payment'),
          headers: _auth(tok),
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 10));

    _parse(res);
  }

  Future<DriverRideModel> arriveAtStop(int rideId, int stopIndex) async {
    final tok = await _token();
    if (tok == null) throw Exception('Not authenticated');

    final res = await http
        .patch(
          Uri.parse('${Api.base}/rides/$rideId/stops/$stopIndex/arrive'),
          headers: _auth(tok),
        )
        .timeout(const Duration(seconds: 10));

    return DriverRideModel.fromJson(_parse(res));
  }

  Future<DriverRideModel> completeStop(int rideId, int stopIndex) async {
    final tok = await _token();
    if (tok == null) throw Exception('Not authenticated');

    final res = await http
        .patch(
          Uri.parse('${Api.base}/rides/$rideId/stops/$stopIndex/complete'),
          headers: _auth(tok),
          body: jsonEncode({}),
        )
        .timeout(const Duration(seconds: 10));

    return DriverRideModel.fromJson(_parse(res));
  }

  Future<Map<String, dynamic>> getPoolInfo(int rideId) async {
    final tok = await _token();
    if (tok == null) throw Exception('Not authenticated');

    final res = await http
        .get(
          Uri.parse('${Api.base}/rides/$rideId/pool'),
          headers: _auth(tok),
        )
        .timeout(const Duration(seconds: 10));

    return _parse(res);
  }

  Future<void> rateRide(int rideId, int rating, {String? comment}) async {
    final tok = await _token();
    if (tok == null) throw Exception('Not authenticated');

    final res = await http
        .post(
          Uri.parse('${Api.base}/rides/$rideId/rate'),
          headers: _auth(tok),
          body: jsonEncode({
            'rating': rating,
            if (comment != null && comment.isNotEmpty) 'comment': comment,
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      throw Exception(data['message'] ?? 'Failed to submit rating');
    }
  }
}

