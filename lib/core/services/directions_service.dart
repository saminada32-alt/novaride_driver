import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../constants/maps_constants.dart';

class DirectionsService {
  DirectionsService._();
  static final DirectionsService instance = DirectionsService._();

  final PolylinePoints _client =
      PolylinePoints.legacy(GoogleMapsConfig.apiKey);

  Future<List<LatLng>> routeBetween(
    LatLng origin,
    LatLng destination, {
    List<LatLng> via = const [],
  }) async {
    if (via.isEmpty) {
      final google = await _googleRoute(origin, destination);
      if (google.length > 2) return google;

      final osrm = await _osrmRoute(origin, destination);
      if (osrm.length > 2) return osrm;

      return _interpolatedRoute(origin, destination, steps: 28);
    }

    final osrm = await _osrmMultiRoute(origin, destination, via);
    if (osrm.length > 2) return osrm;

    var cursor = origin;
    final merged = <LatLng>[];
    for (final stop in via) {
      final seg = await routeBetween(cursor, stop);
      if (merged.isNotEmpty && seg.isNotEmpty) seg.removeAt(0);
      merged.addAll(seg);
      cursor = stop;
    }
    final last = await routeBetween(cursor, destination);
    if (merged.isNotEmpty && last.isNotEmpty) last.removeAt(0);
    merged.addAll(last);
    return merged.length >= 2 ? merged : _interpolatedRoute(origin, destination);
  }

  Future<List<LatLng>> _osrmMultiRoute(
    LatLng origin,
    LatLng destination,
    List<LatLng> via,
  ) async {
    try {
      final coords = [
        '${origin.longitude},${origin.latitude}',
        ...via.map((p) => '${p.longitude},${p.latitude}'),
        '${destination.longitude},${destination.latitude}',
      ];
      final uri = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/${coords.join(';')}'
        '?overview=full&geometries=geojson',
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) return [];

      final data = jsonDecode(utf8.decode(res.bodyBytes));
      final routeCoords = data['routes']?[0]?['geometry']?['coordinates'] as List?;
      if (routeCoords == null || routeCoords.isEmpty) return [];
      return routeCoords
          .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
          .toList();
    } catch (e) {
      debugPrint('OSRM multi-route error: $e');
      return [];
    }
  }

  Future<List<LatLng>> _googleRoute(LatLng origin, LatLng destination) async {
    try {
      final result = await _client.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(origin.latitude, origin.longitude),
          destination: PointLatLng(destination.latitude, destination.longitude),
          mode: TravelMode.driving,
        ),
      );

      if (result.status == 'OK' && result.points.isNotEmpty) {
        return result.points
            .map((p) => LatLng(p.latitude, p.longitude))
            .toList();
      }
      debugPrint('Directions status: ${result.status}');
    } catch (e) {
      debugPrint('Directions error: $e');
    }
    return [];
  }

  Future<List<LatLng>> _osrmRoute(LatLng origin, LatLng destination) async {
    try {
      final path =
          '${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}';
      final uri = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/$path'
        '?overview=full&geometries=geojson',
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) return [];

      final data = jsonDecode(utf8.decode(res.bodyBytes));
      final coords = data['routes']?[0]?['geometry']?['coordinates'] as List?;
      if (coords == null || coords.isEmpty) return [];

      return coords
          .map((c) => LatLng(
                (c[1] as num).toDouble(),
                (c[0] as num).toDouble(),
              ))
          .toList();
    } catch (e) {
      debugPrint('OSRM route error: $e');
    }
    return [];
  }

  List<LatLng> _interpolatedRoute(
    LatLng origin,
    LatLng destination, {
    int steps = 24,
  }) {
    final points = <LatLng>[];
    final midLat = (origin.latitude + destination.latitude) / 2;
    final midLng = (origin.longitude + destination.longitude) / 2;
    final dist = _haversineMeters(origin, destination);
    final bend = (dist * 0.000008).clamp(0.0003, 0.004);

    for (var i = 0; i <= steps; i++) {
      final t = i / steps;
      final lat = origin.latitude + (destination.latitude - origin.latitude) * t;
      final lng = origin.longitude + (destination.longitude - origin.longitude) * t;
      final curve = math.sin(t * math.pi) * bend;
      points.add(LatLng(lat + curve, lng - curve * 0.5));
    }
    points[points.length ~/ 2] = LatLng(midLat + bend, midLng);
    return points;
  }

  double _haversineMeters(LatLng a, LatLng b) {
    const r = 6371000.0;
    final dLat = _toRad(b.latitude - a.latitude);
    final dLng = _toRad(b.longitude - a.longitude);
    final x = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(a.latitude)) *
            math.cos(_toRad(b.latitude)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return r * 2 * math.atan2(math.sqrt(x), math.sqrt(1 - x));
  }

  double _toRad(double deg) => deg * math.pi / 180;
}
