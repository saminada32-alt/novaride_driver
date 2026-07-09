import 'package:flutter/material.dart';
import '../../../../../core/utils/currency_utils.dart';
import '../../../../../l10n/app_localizations.dart';
import '../model/ride_model.dart';
import 'active_ride_ui.dart';

class ActiveRideBottomSheet extends StatelessWidget {
  final ScrollController scrollController;
  final DriverRideModel ride;
  final AppLocalizations t;
  final String passengerName;
  final String passengerRatingText;
  final Map<String, dynamic>? passenger;
  final bool audioRecording;
  final bool updating;
  final bool navigatingToDropoff;
  final int legIndex;
  final String? currentLegLabel;
  final Animation<double> btnScale;
  final VoidCallback onToggleAudio;
  final VoidCallback onMessage;
  final VoidCallback onCall;
  final VoidCallback onUpdateStatus;
  final Future<void> Function() onCancelRide;
  final VoidCallback? onShowRoute;

  const ActiveRideBottomSheet({
    super.key,
    required this.scrollController,
    required this.ride,
    required this.t,
    required this.passengerName,
    required this.passengerRatingText,
    required this.passenger,
    required this.audioRecording,
    required this.updating,
    required this.navigatingToDropoff,
    required this.legIndex,
    required this.currentLegLabel,
    required this.btnScale,
    required this.onToggleAudio,
    required this.onMessage,
    required this.onCall,
    required this.onUpdateStatus,
    required this.onCancelRide,
    this.onShowRoute,
  });

  Future<void> _showMoreMenu(BuildContext context) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onShowRoute != null)
              ListTile(
                leading: const Icon(Icons.map_rounded),
                title: Text(t.rideTripDetails),
                onTap: () => Navigator.pop(ctx, 'route'),
              ),
            if (ride.status == DriverRideStatus.driver_assigned)
              ListTile(
                leading: const Icon(Icons.cancel_outlined, color: Colors.red),
                title: Text(
                  t.rideCancelRide,
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: () => Navigator.pop(ctx, 'cancel'),
              ),
          ],
        ),
      ),
    );

    if (!context.mounted) return;
    if (action == 'route') onShowRoute?.call();
    if (action == 'cancel') {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(t.rideCancelTitle),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(t.no),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(t.yes, style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      if (ok == true) await onCancelRide();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasNext = ride.nextStatus != null;
    final pickup = ride.pickupAddress ??
        '${ride.pickupLat.toStringAsFixed(4)}, ${ride.pickupLng.toStringAsFixed(4)}';
    final dropoff = ride.dropoffAddress ??
        '${ride.dropoffLat.toStringAsFixed(4)}, ${ride.dropoffLng.toStringAsFixed(4)}';
    final waypointLabels = ride.waypoints
        .map(
          (w) =>
              w.address ??
              '${w.lat.toStringAsFixed(4)}, ${w.lng.toStringAsFixed(4)}',
        )
        .toList();
    final etaHeadline = ActiveRideUi.etaHeroText(
      ride.status,
      ride.etaMinutes,
      t,
    );
    final instruction = ActiveRideUi.instructionText(ride.status, t);
    final fareText = CurrencyUtils.formatSyp(ride.estimatedFare);
    final avatarUrl = passenger?['avatarUrl']?.toString();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ListView(
        controller: scrollController,
        padding: EdgeInsets.zero,
        children: [
          ActiveRideUi.sheetHandle(),
          ActiveRideUi.etaHeadline(etaHeadline),
          ActiveRideUi.safetyAudioCard(
            t: t,
            recording: audioRecording,
            onToggle: onToggleAudio,
          ),
          ActiveRideUi.tripInstructionCard(
            t: t,
            instruction: instruction,
            onMore: () => _showMoreMenu(context),
          ),
          if (passenger != null)
            ActiveRideUi.passengerCard(
              t: t,
              name: passengerName,
              ratingText: passengerRatingText,
              fareText: fareText,
              subtitle: ActiveRideUi.fareSubtitle(ride, t),
              avatarUrl: avatarUrl,
              onMessage: onMessage,
              onCall: onCall,
              onMore: () => _showMoreMenu(context),
            ),
          if (ride.hasPromoDiscount)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Text(
                '${ride.promoCode} · −${CurrencyUtils.formatSyp(ride.discountAmount)}',
                style: const TextStyle(
                  color: Color(0xFF4ade80),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ActiveRideUi.routeTimelineCard(
            t: t,
            pickup: pickup,
            dropoff: dropoff,
            waypointLabels: waypointLabels,
            activeWaypointIndex: legIndex,
            navigatingToDropoff: navigatingToDropoff,
          ),
          if (ride.accessibilityRequired)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.accessible, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        t.accessibilityRide,
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (navigatingToDropoff &&
              ride.hasMultiStop &&
              currentLegLabel != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                '${t.multiStopNext}: $currentLegLabel',
                style: TextStyle(
                  color: Colors.orange.shade800,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                ActiveRideUi.chip(
                  Icons.confirmation_number_outlined,
                  t.rideNumber(ride.id),
                  Colors.grey,
                ),
                if (ride.etaMinutes != null) ...[
                  const SizedBox(width: 8),
                  ActiveRideUi.chip(
                    Icons.schedule_rounded,
                    '${ride.etaMinutes} ${t.minutesShort}',
                    Colors.blue,
                  ),
                ],
              ],
            ),
          ),
          if (hasNext)
            ActiveRideUi.primaryActionButton(
              label: ActiveRideUi.nextButtonLabel(ride.status, t),
              updating: updating,
              scale: btnScale,
              onTap: onUpdateStatus,
            ),
          if (ride.status == DriverRideStatus.driver_assigned)
            Center(
              child: TextButton(
                onPressed: updating
                    ? null
                    : () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(t.rideCancelTitle),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: Text(t.no),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: Text(
                                  t.yes,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (ok == true) await onCancelRide();
                      },
                child: Text(
                  t.rideCancelRide,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
        ],
      ),
    );
  }
}
