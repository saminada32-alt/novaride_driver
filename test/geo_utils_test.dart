import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:novaride_driver/core/utils/geo_utils.dart';

void main() {
  group('GeoUtils.distanceKm', () {
    test('same point is zero distance', () {
      const p = LatLng(33.5138, 36.2765);
      expect(GeoUtils.distanceKm(p, p), closeTo(0, 1e-9));
    });

    test('is symmetric', () {
      const a = LatLng(33.5138, 36.2765); // Damascus
      const b = LatLng(36.2021, 37.1343); // Aleppo
      expect(GeoUtils.distanceKm(a, b), closeTo(GeoUtils.distanceKm(b, a), 1e-9));
    });

    test('matches the known ~111.19km for one degree of longitude at the equator', () {
      const a = LatLng(0, 0);
      const b = LatLng(0, 1);
      // Earth radius * (pi/180), for the great-circle approximation this
      // GeoUtils implementation uses (mean radius = 6371km).
      expect(GeoUtils.distanceKm(a, b), closeTo(111.19, 0.01));
    });

    test('Damascus ↔ Aleppo is roughly 300km (sanity bound on real driver offers)', () {
      const damascus = LatLng(33.5138, 36.2765);
      const aleppo = LatLng(36.2021, 37.1343);
      final d = GeoUtils.distanceKm(damascus, aleppo);
      expect(d, greaterThan(280));
      expect(d, lessThan(320));
    });

    test('a nearby pickup point (~1km away) stays within dispatch\'s tightest radius', () {
      // src/dispatch/dispatch.service.ts defaults radiuses to [1, 3, 5, 8, 12] km.
      const pickup = LatLng(33.5138, 36.2765);
      const nearbyDriver = LatLng(33.5228, 36.2765); // ~1 degree*0.01 lat north
      expect(GeoUtils.distanceKm(pickup, nearbyDriver), lessThan(1.5));
    });
  });
}
