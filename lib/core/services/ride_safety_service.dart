import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class DriverRideSafetyService {
  DriverRideSafetyService._();
  static DriverRideSafetyService instance = DriverRideSafetyService._();

  static const _storage = FlutterSecureStorage();

  Future<String?> _token() => _storage.read(key: 'driver_token');

  Future<Position?> currentPosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return null;
      }
      return Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Future<bool> triggerSos(int rideId, {double? lat, double? lng}) async {
    final tok = await _token();
    if (tok == null) return false;

    final res = await http
        .post(
          Uri.parse('${Api.base}/rides/$rideId/sos'),
          headers: {
            'Authorization': 'Bearer $tok',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            if (lat != null) 'lat': lat,
            if (lng != null) 'lng': lng,
          }),
        )
        .timeout(const Duration(seconds: 15));

    return res.statusCode >= 200 && res.statusCode < 300;
  }
}
