import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

typedef DriverLocationCallback = void Function(double lat, double lng);

class DriverBackgroundLocationService {
  DriverBackgroundLocationService._();
  static final instance = DriverBackgroundLocationService._();

  StreamSubscription<Position>? _sub;
  DriverLocationCallback? onPosition;

  Future<bool> ensurePermission() async {
    var serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) return false;

    if (Platform.isAndroid && permission == LocationPermission.whileInUse) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<void> start() async {
    await stop();
    if (!await ensurePermission()) {
      if (kDebugMode) debugPrint('Background location permission denied');
      return;
    }

    final settings = Platform.isAndroid
        ? AndroidSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 15,
            foregroundNotificationConfig: const ForegroundNotificationConfig(
              notificationTitle: 'NovaRide Driver',
              notificationText: 'Location active while you are online',
              enableWakeLock: true,
            ),
          )
        : AppleSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 15,
            showBackgroundLocationIndicator: true,
          );

    _sub = Geolocator.getPositionStream(locationSettings: settings).listen(
      (p) => onPosition?.call(p.latitude, p.longitude),
      onError: (e) {
        if (kDebugMode) debugPrint('Background location error: $e');
      },
    );
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
  }
}
