import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import '../utils/geo_utils.dart';
import '../utils/syria_city_coords.dart';
import 'work_zones_service.dart';

enum LocationGuardFailure {
  permissionDenied,
  serviceDisabled,
  noFix,
  outsideWorkZone,
}

class LocationGuardResult {
  final LatLng? position;
  final LocationGuardFailure? failure;

  const LocationGuardResult({this.position, this.failure});

  bool get ok => position != null && failure == null;
}

class DriverLocationGuard {
  DriverLocationGuard._();

  static const double maxCityRadiusKm = 40;
  static const _gpsTimeout = Duration(seconds: 4);
  static const _cachedMaxAge = Duration(seconds: 60);

  static Future<LocationGuardResult> checkBeforeOnline(
    Location loc, {
    LatLng? cachedPosition,
    DateTime? cachedAt,
  }) async {
    var perm = await loc.hasPermission();
    if (perm == PermissionStatus.denied) {
      perm = await loc.requestPermission();
    }
    if (perm != PermissionStatus.granted &&
        perm != PermissionStatus.grantedLimited) {
      return const LocationGuardResult(
        failure: LocationGuardFailure.permissionDenied,
      );
    }

    var serviceOn = await loc.serviceEnabled();
    if (!serviceOn) {
      serviceOn = await loc.requestService();
      if (!serviceOn) {
        return const LocationGuardResult(
          failure: LocationGuardFailure.serviceDisabled,
        );
      }
    }

    LatLng? pos;
    if (cachedPosition != null &&
        cachedAt != null &&
        DateTime.now().difference(cachedAt) < _cachedMaxAge) {
      pos = cachedPosition;
    } else {
      try {
        final data = await loc.getLocation().timeout(_gpsTimeout);
        final lat = data.latitude;
        final lng = data.longitude;
        if (lat != null && lng != null) {
          pos = LatLng(lat, lng);
        }
      } on TimeoutException {
        if (cachedPosition != null) {
          pos = cachedPosition;
        } else {
          return const LocationGuardResult(failure: LocationGuardFailure.noFix);
        }
      }
    }

    if (pos == null) {
      return const LocationGuardResult(failure: LocationGuardFailure.noFix);
    }

    final zones = await WorkZonesService.instance.list();
    if (zones.isEmpty) {
      return LocationGuardResult(position: pos);
    }

    final inZone = zones.any((z) {
      final center = SyriaCityCoords.forCity(z.city);
      return GeoUtils.distanceKm(pos!, center) <= maxCityRadiusKm;
    });

    if (!inZone) {
      return const LocationGuardResult(
        failure: LocationGuardFailure.outsideWorkZone,
      );
    }

    return LocationGuardResult(position: pos);
  }
}
