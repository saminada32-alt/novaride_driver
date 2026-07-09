import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class NavStep {
  final String instruction;
  final LatLng location;
  final double distanceMeters;

  NavStep({
    required this.instruction,
    required this.location,
    required this.distanceMeters,
  });
}

class RouteNavigationService {
  RouteNavigationService._();
  static final RouteNavigationService instance = RouteNavigationService._();

  final FlutterTts _tts = FlutterTts();
  List<NavStep> _steps = [];
  int _currentIndex = 0;
  bool _enabled = false;
  bool _ttsReady = false;

  bool get isEnabled => _enabled;
  List<NavStep> get steps => List.unmodifiable(_steps);

  Future<void> initTts() async {
    if (_ttsReady) return;
    await _tts.setLanguage('ar');
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1);
    _ttsReady = true;
  }

  Future<void> setEnabled(bool value) async {
    _enabled = value;
    if (value) await initTts();
    if (!value) await _tts.stop();
  }

  Future<List<LatLng>> loadRouteWithVoice(
    LatLng origin,
    LatLng destination, {
    List<LatLng> via = const [],
  }) async {
    _steps = [];
    _currentIndex = 0;

    try {
      final coords = [
        '${origin.longitude},${origin.latitude}',
        ...via.map((p) => '${p.longitude},${p.latitude}'),
        '${destination.longitude},${destination.latitude}',
      ];
      final path = coords.join(';');
      final uri = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/$path'
        '?steps=true&geometries=geojson&overview=full',
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) return [];

      final data = jsonDecode(utf8.decode(res.bodyBytes));
      final route = data['routes']?[0];
      if (route == null) return [];

      final routeCoords = route['geometry']?['coordinates'] as List?;
      final legs = route['legs'] as List?;
      if (legs != null && legs.isNotEmpty) {
        final osrmSteps = legs[0]['steps'] as List? ?? [];
        for (final s in osrmSteps) {
          final maneuver = s['maneuver'] as Map?;
          final loc = maneuver?['location'] as List?;
          if (loc == null || loc.length < 2) continue;
          final name = maneuver?['name']?.toString() ?? '';
          final modifier = maneuver?['modifier']?.toString() ?? '';
          final type = maneuver?['type']?.toString() ?? '';
          var text = [type, modifier, name].where((e) => e.isNotEmpty).join(' ');
          if (text.isEmpty) text = 'تابع على المسار';
          _steps.add(
            NavStep(
              instruction: text,
              location: LatLng(
                (loc[1] as num).toDouble(),
                (loc[0] as num).toDouble(),
              ),
              distanceMeters: (s['distance'] as num?)?.toDouble() ?? 0,
            ),
          );
        }
      }

      if (routeCoords == null || routeCoords.isEmpty) return [];
      return routeCoords
          .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
          .toList();
    } catch (e) {
      debugPrint('OSRM nav error: $e');
      return [];
    }
  }

  void onDriverPosition(LatLng pos) {
    if (!_enabled || _steps.isEmpty) return;

    while (_currentIndex < _steps.length - 1) {
      final next = _steps[_currentIndex + 1];
      if (_distanceMeters(pos, next.location) > 35) break;
      _currentIndex++;
      _speak(next.instruction);
    }
  }

  Future<void> _speak(String text) async {
    if (!_enabled || !_ttsReady) return;
    await _tts.stop();
    await _tts.speak(text);
  }

  double _distanceMeters(LatLng a, LatLng b) {
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

  double _toRad(double d) => d * math.pi / 180;

  Future<void> dispose() async {
    await _tts.stop();
  }
}
