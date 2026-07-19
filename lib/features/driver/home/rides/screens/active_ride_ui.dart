import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';
import '../model/ride_model.dart';

/// Uber/Bolt-style UI helpers for the active ride screen.
class ActiveRideUi {
  ActiveRideUi._();

  static const Color _uberBlack = Color(0xFF000000);
  static const Color _safetyBlue = Color(0xFFE8F4FD);

  static Color statusColor(DriverRideStatus status) {
    switch (status) {
      case DriverRideStatus.driver_assigned:
        return Colors.blue;
      case DriverRideStatus.driver_arrived:
        return Colors.green;
      case DriverRideStatus.passenger_onboard:
        return Colors.teal;
      case DriverRideStatus.trip_started:
        return _uberBlack;
      default:
        return Colors.grey;
    }
  }

  static String tripStatusLabel(DriverRideStatus status, AppLocalizations t) {
    switch (status) {
      case DriverRideStatus.scheduled:
        return t.tripStatusScheduled;
      case DriverRideStatus.searching:
        return t.tripStatusSearching;
      case DriverRideStatus.driver_assigned:
        return t.tripStatusAssigned;
      case DriverRideStatus.driver_arrived:
        return t.tripStatusArrived;
      case DriverRideStatus.passenger_onboard:
        return t.tripStatusOnboard;
      case DriverRideStatus.trip_started:
        return t.tripStatusStarted;
      case DriverRideStatus.completed:
        return t.tripStatusCompleted;
      case DriverRideStatus.cancelled:
        return t.tripStatusCancelled;
    }
  }

  static String statusTitle(DriverRideStatus status, AppLocalizations t) {
    switch (status) {
      case DriverRideStatus.driver_assigned:
        return t.rideHeadToPickup;
      case DriverRideStatus.driver_arrived:
        return t.rideWaitingPassenger;
      case DriverRideStatus.passenger_onboard:
        return t.ridePassengerOnBoard;
      case DriverRideStatus.trip_started:
        return t.rideInProgress;
      default:
        return status.name.replaceAll('_', ' ');
    }
  }

  static String instructionText(DriverRideStatus status, AppLocalizations t) {
    switch (status) {
      case DriverRideStatus.driver_assigned:
      case DriverRideStatus.driver_arrived:
        return t.activeRideMeetPassenger;
      case DriverRideStatus.passenger_onboard:
        return t.ridePassengerOnBoard;
      case DriverRideStatus.trip_started:
        return t.rideInProgress;
      default:
        return t.rideTripDetailsHint;
    }
  }

  static String nextButtonLabel(DriverRideStatus status, AppLocalizations t) {
    switch (status) {
      case DriverRideStatus.driver_assigned:
        return t.rideBtnArrived;
      case DriverRideStatus.driver_arrived:
        return t.rideBtnPassengerOnBoard;
      case DriverRideStatus.passenger_onboard:
        return t.rideBtnStartTrip;
      case DriverRideStatus.trip_started:
        return t.rideBtnCompleteTrip;
      default:
        return '';
    }
  }

  static Widget statusIcon(DriverRideStatus status, {bool onDark = true}) {
    final color = onDark ? Colors.white : statusColor(status);
    switch (status) {
      case DriverRideStatus.driver_assigned:
        return Icon(Icons.directions_car_rounded, color: color, size: 20);
      case DriverRideStatus.driver_arrived:
        return Icon(Icons.location_on_rounded, color: color, size: 20);
      case DriverRideStatus.passenger_onboard:
        return Icon(Icons.airline_seat_recline_normal_rounded,
            color: color, size: 20);
      case DriverRideStatus.trip_started:
        return Icon(Icons.navigation_rounded, color: color, size: 20);
      default:
        return Icon(Icons.info_rounded, color: color, size: 20);
    }
  }

  static String etaHeroText(
    DriverRideStatus status,
    int? etaMinutes,
    AppLocalizations t,
  ) {
    final minutes = etaMinutes ?? 0;
    switch (status) {
      case DriverRideStatus.driver_assigned:
      case DriverRideStatus.driver_arrived:
        return minutes > 0
            ? t.activeRideMeetPassengerEta(minutes)
            : t.rideHeadToPickup;
      case DriverRideStatus.trip_started:
        return minutes > 0
            ? t.activeRideArriveDropoffEta(minutes)
            : t.rideInProgress;
      default:
        return statusTitle(status, t);
    }
  }

  static Widget sheetHandle() => Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 6),
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      );

  static Widget etaHeadline(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 24,
            height: 1.25,
            color: _uberBlack,
          ),
        ),
      );

  static Widget safetyAudioCard({
    required AppLocalizations t,
    required bool recording,
    required VoidCallback onToggle,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: _safetyBlue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                recording ? Icons.mic_rounded : Icons.mic_none_rounded,
                color: recording ? Colors.red.shade700 : Colors.blue.shade800,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  recording ? t.safetyRecording : t.safetyRecordAudio,
                  style: TextStyle(
                    color: Colors.blue.shade900,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              TextButton(
                onPressed: onToggle,
                style: TextButton.styleFrom(
                  foregroundColor: recording ? Colors.red : Colors.blue.shade900,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
                child: Text(
                  recording ? '■' : t.safetyRecordStart,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );

  static Widget tripInstructionCard({
    required AppLocalizations t,
    required String instruction,
    VoidCallback? onMore,
  }) =>
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (onMore != null)
                IconButton(
                  onPressed: onMore,
                  icon: const Icon(Icons.more_horiz_rounded),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  color: Colors.grey.shade700,
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.rideTripDetails,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      instruction,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        height: 1.3,
                        color: _uberBlack,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  static Widget passengerCard({
    required AppLocalizations t,
    required String name,
    required String ratingText,
    required String fareText,
    required String subtitle,
    String? avatarUrl,
    VoidCallback? onMessage,
    VoidCallback? onCall,
    VoidCallback? onMore,
  }) =>
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        _passengerAvatar(name, avatarUrl),
                        const SizedBox(height: 8),
                        _ratingPill(ratingText),
                        const SizedBox(height: 6),
                        Text(
                          name.isNotEmpty ? name : t.ridePassengerLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: _uberBlack,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fareText,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 22,
                              color: _uberBlack,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    if (onMessage != null)
                      Expanded(
                        child: _contactButton(
                          icon: Icons.chat_bubble_outline_rounded,
                          label: t.sendMessage,
                          onTap: onMessage,
                          expanded: true,
                        ),
                      ),
                    if (onCall != null) ...[
                      const SizedBox(width: 8),
                      _contactButton(
                        icon: Icons.call_rounded,
                        onTap: onCall,
                      ),
                    ],
                    if (onMore != null) ...[
                      const SizedBox(width: 8),
                      _contactButton(
                        icon: Icons.more_horiz_rounded,
                        onTap: onMore,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  static Widget _passengerAvatar(String name, String? url) {
    final initials = name.trim().isNotEmpty
        ? name.trim().split(' ').map((p) => p.isNotEmpty ? p[0] : '').take(2).join()
        : '?';
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        shape: BoxShape.circle,
        image: url != null && url.isNotEmpty
            ? DecorationImage(image: NetworkImage(url), fit: BoxFit.cover)
            : null,
      ),
      child: url == null || url.isEmpty
          ? Center(
              child: Text(
                initials.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.grey.shade700,
                ),
              ),
            )
          : null,
    );
  }

  static Widget _ratingPill(String rating) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              rating,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: _uberBlack,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
          ],
        ),
      );

  static Widget _contactButton({
    required IconData icon,
    String? label,
    required VoidCallback onTap,
    bool expanded = false,
  }) =>
      Material(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 48,
            padding: EdgeInsets.symmetric(
              horizontal: expanded ? 16 : 0,
              vertical: 12,
            ),
            constraints: BoxConstraints(
              minWidth: expanded ? 0 : 48,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 22, color: _uberBlack),
                if (label != null) ...[
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: _uberBlack,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );

  static Widget mapDistanceChip(String text) => Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: _uberBlack,
            ),
          ),
        ),
      );

  static Widget mapPickupLabel(String text) => Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(20),
        color: _uberBlack,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      );

  static Widget routeTimelineCard({
    required AppLocalizations t,
    required String pickup,
    required String dropoff,
    required List<String> waypointLabels,
    int? activeWaypointIndex,
    bool navigatingToDropoff = false,
  }) =>
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              routeRow(
                Colors.green,
                Icons.radio_button_checked_rounded,
                t.ridePickupLabel,
                pickup,
              ),
              Container(
                margin: const EdgeInsets.only(left: 11),
                width: 2,
                height: 16,
                color: Colors.grey.shade300,
              ),
              for (var i = 0; i < waypointLabels.length; i++) ...[
                routeRow(
                  i == activeWaypointIndex && navigatingToDropoff
                      ? Colors.orange
                      : Colors.amber,
                  Icons.pin_drop_rounded,
                  '${t.multiStopLabel} ${i + 1}',
                  waypointLabels[i],
                ),
                Container(
                  margin: const EdgeInsets.only(left: 11),
                  width: 2,
                  height: 16,
                  color: Colors.grey.shade300,
                ),
              ],
              routeRow(
                Colors.red,
                Icons.location_on_rounded,
                t.rideDropoffLabel,
                dropoff,
              ),
            ],
          ),
        ),
      );

  static Widget primaryActionButton({
    required String label,
    required bool updating,
    required Animation<double> scale,
    required VoidCallback onTap,
  }) =>
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: ScaleTransition(
          scale: scale,
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: updating ? null : onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: _uberBlack,
                disabledBackgroundColor: Colors.grey.shade400,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: updating
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ),
      );

  static Widget largeActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) =>
      Expanded(
        child: Material(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color, size: 22),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  static Widget actionBtn(IconData icon, Color color, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
      );

  static Widget routeRow(Color c, IconData icon, String title, String sub) =>
      Row(
        children: [
          Icon(icon, color: c, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  sub,
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      );

  static Widget chip(IconData icon, String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 5),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );

  static String fareSubtitle(DriverRideModel ride, AppLocalizations t) {
    if (ride.estimatedDistanceKm != null) {
      return t.distanceKmUnit(ride.estimatedDistanceKm!.toStringAsFixed(1));
    }
    return ride.pickupAddress ?? t.ridePickupPoint;
  }

  static Widget paymentOption(
    IconData icon,
    String label,
    Color color,
    bool selected,
    VoidCallback onTap,
  ) =>
      Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  selected ? color.withValues(alpha: 0.1) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: selected ? Border.all(color: color, width: 2) : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: selected ? color : Colors.grey, size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight:
                          selected ? FontWeight.bold : FontWeight.normal,
                      color: selected ? color : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
