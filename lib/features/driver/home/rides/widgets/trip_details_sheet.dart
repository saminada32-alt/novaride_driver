import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../core/widgets/fare_with_promo.dart';
import '../model/ride_model.dart';

/// Read-only trip details bottom sheet — shared by the trips history list
/// and the earnings recent-transactions list, so both entry points show
/// the same full picture for a given ride.
class TripDetailsSheet extends StatelessWidget {
  final DriverRideModel trip;
  final Color statusColor;
  final String statusLabel;
  final String dateLabel;

  const TripDetailsSheet({
    super.key,
    required this.trip,
    required this.statusColor,
    required this.statusLabel,
    required this.dateLabel,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final passengerName =
        '${trip.passenger?['firstName'] ?? ''} ${trip.passenger?['lastName'] ?? ''}'
            .trim();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    t.rideNumber(trip.id),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(dateLabel, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            const SizedBox(height: 20),
            _row(
              Icons.radio_button_checked_rounded,
              Colors.green,
              trip.pickupAddress ??
                  '${trip.pickupLat.toStringAsFixed(4)}, ${trip.pickupLng.toStringAsFixed(4)}',
            ),
            const SizedBox(height: 10),
            _row(
              Icons.location_on_rounded,
              Colors.red,
              trip.dropoffAddress ??
                  '${trip.dropoffLat.toStringAsFixed(4)}, ${trip.dropoffLng.toStringAsFixed(4)}',
            ),
            if (passengerName.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.person_rounded, size: 16, color: Colors.blueGrey),
                  const SizedBox(width: 10),
                  Text(passengerName, style: const TextStyle(fontSize: 13)),
                ],
              ),
            ],
            if (trip.estimatedDistanceKm != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.straighten_rounded, size: 16, color: Colors.blueGrey),
                  const SizedBox(width: 10),
                  Text(
                    '${trip.estimatedDistanceKm!.toStringAsFixed(1)} km',
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Text(t.fare, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                const Spacer(),
                FareWithPromo(
                  ride: trip,
                  compact: true,
                  alignment: CrossAxisAlignment.end,
                  fareStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, Color color, String text) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      );
}
