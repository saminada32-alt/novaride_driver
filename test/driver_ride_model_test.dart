import 'package:flutter_test/flutter_test.dart';
import 'package:novaride_driver/features/driver/home/rides/model/ride_model.dart';

Map<String, dynamic> baseRideJson({
  String status = 'SEARCHING',
  Map<String, dynamic>? extra,
}) => {
  'id': 42,
  'status': status,
  'pickupLat': 33.5138,
  'pickupLng': 36.2765,
  'dropoffLat': 33.52,
  'dropoffLng': 36.29,
  ...?extra,
};

void main() {
  group('DriverRideModel.fromJson — status parsing (must match backend RideStatus enum)', () {
    const backendToClient = {
      'SEARCHING': DriverRideStatus.searching,
      'SCHEDULED': DriverRideStatus.scheduled,
      'DRIVER_ASSIGNED': DriverRideStatus.driver_assigned,
      'DRIVER_ARRIVED': DriverRideStatus.driver_arrived,
      'PASSENGER_ONBOARD': DriverRideStatus.passenger_onboard,
      'TRIP_STARTED': DriverRideStatus.trip_started,
      'COMPLETED': DriverRideStatus.completed,
      'CANCELLED': DriverRideStatus.cancelled,
    };

    backendToClient.forEach((backendValue, expected) {
      test('"$backendValue" → $expected', () {
        expect(DriverRideModel.fromJson(baseRideJson(status: backendValue)).status, expected);
      });
    });

    test('an unknown backend status (e.g. NO_DRIVER_FOUND) falls back to searching, not a crash', () {
      expect(
        DriverRideModel.fromJson(baseRideJson(status: 'NO_DRIVER_FOUND')).status,
        DriverRideStatus.searching,
      );
    });

    test('lowercase backend value still parses (status match is case-insensitive)', () {
      expect(
        DriverRideModel.fromJson(baseRideJson(status: 'driver_assigned')).status,
        DriverRideStatus.driver_assigned,
      );
    });
  });

  group('DriverRideModel — status progression must mirror the backend ALLOWED_TRANSITIONS', () {
    // src/rides/rides.service.ts: SEARCHING→DRIVER_ASSIGNED→DRIVER_ARRIVED→
    // PASSENGER_ONBOARD→TRIP_STARTED→COMPLETED. If the driver app's "next
    // status" button ever falls out of sync with this, drivers get a
    // rejected PATCH /rides/:id/status and a stuck trip screen.
    test('nextStatus follows the exact backend-allowed sequence', () {
      final sequence = [
        DriverRideStatus.driver_assigned,
        DriverRideStatus.driver_arrived,
        DriverRideStatus.passenger_onboard,
        DriverRideStatus.trip_started,
        DriverRideStatus.completed,
      ];
      for (var i = 0; i < sequence.length - 1; i++) {
        final ride = DriverRideModel.fromJson(
          baseRideJson(status: sequence[i].name.toUpperCase()),
        );
        expect(ride.nextStatus, sequence[i + 1], reason: 'from ${sequence[i]}');
      }
    });

    test('completed/cancelled/searching have no next status', () {
      for (final status in ['COMPLETED', 'CANCELLED', 'SEARCHING']) {
        final ride = DriverRideModel.fromJson(baseRideJson(status: status));
        expect(ride.nextStatus, isNull, reason: status);
      }
    });

    test('every actionable status has a non-empty next-status label', () {
      for (final status in [
        DriverRideStatus.driver_assigned,
        DriverRideStatus.driver_arrived,
        DriverRideStatus.passenger_onboard,
        DriverRideStatus.trip_started,
      ]) {
        final ride = DriverRideModel.fromJson(
          baseRideJson(status: status.name.toUpperCase()),
        );
        expect(ride.nextStatusLabel, isNotEmpty, reason: '$status');
      }
    });
  });

  group('DriverRideModel — derived state getters', () {
    test('isActive true only for the four in-progress statuses', () {
      const active = {
        DriverRideStatus.driver_assigned,
        DriverRideStatus.driver_arrived,
        DriverRideStatus.passenger_onboard,
        DriverRideStatus.trip_started,
      };
      for (final status in DriverRideStatus.values) {
        final ride = DriverRideModel.fromJson(
          baseRideJson(status: status.name.toUpperCase()),
        );
        expect(ride.isActive, active.contains(status), reason: '$status');
      }
    });

    test('passengerPhone reads from the nested passenger map', () {
      final ride = DriverRideModel.fromJson(baseRideJson(extra: {
        'passenger': {'phone': '+963944123456'},
      }));
      expect(ride.passengerPhone, '+963944123456');
      expect(DriverRideModel.fromJson(baseRideJson()).passengerPhone, isNull);
    });

    test('hasPromoDiscount requires both a promo code and a positive discount', () {
      final withDiscount = DriverRideModel.fromJson(baseRideJson(extra: {
        'promoCode': 'WELCOME10',
        'discountAmount': 2000,
      }));
      expect(withDiscount.hasPromoDiscount, isTrue);

      final zeroDiscount = DriverRideModel.fromJson(baseRideJson(extra: {
        'promoCode': 'WELCOME10',
        'discountAmount': 0,
      }));
      expect(zeroDiscount.hasPromoDiscount, isFalse);

      expect(DriverRideModel.fromJson(baseRideJson()).hasPromoDiscount, isFalse);
    });

    test('filters out placeholder (near 0,0) waypoints', () {
      final ride = DriverRideModel.fromJson(baseRideJson(extra: {
        'waypoints': [
          {'lat': 33.51, 'lng': 36.28, 'address': 'real stop'},
          {'lat': 0, 'lng': 0},
        ],
      }));
      expect(ride.waypoints, hasLength(1));
      expect(ride.hasMultiStop, isTrue);
    });

    test('isScheduledRide: true when isScheduled flag or scheduledAt is in the future', () {
      final future = DateTime.now().add(const Duration(hours: 1)).toIso8601String();
      final ride = DriverRideModel.fromJson(baseRideJson(extra: {'scheduledAt': future}));
      expect(ride.isScheduledRide, isTrue);

      final past = DateTime.now().subtract(const Duration(hours: 1)).toIso8601String();
      final pastRide = DriverRideModel.fromJson(baseRideJson(extra: {'scheduledAt': past}));
      expect(pastRide.isScheduledRide, isFalse);
    });
  });
}
