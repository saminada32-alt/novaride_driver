import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/widgets/fare_with_promo.dart';
import '../../../../l10n/app_localizations.dart';
import '../../driver/home/rides/model/ride_model.dart';

class IncomingRideDialog extends StatefulWidget {
  final DriverRideModel ride;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const IncomingRideDialog({
    super.key,
    required this.ride,
    required this.onAccept,
    required this.onReject,
  });

  @override
  State<IncomingRideDialog> createState() => IncomingRideDialogState();
}

class IncomingRideDialogState extends State<IncomingRideDialog>
    with SingleTickerProviderStateMixin {
  int _countdown = 20;
  Timer? _timer;
  Timer? _ringTimer;
  late AnimationController _ringCtrl;
  late Animation<double> _ring;

  @override
  void initState() {
    super.initState();

    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _ring = Tween<double>(
      begin: 0.9,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _ringCtrl, curve: Curves.easeInOut));

    HapticFeedback.heavyImpact();
    _ringTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      SystemSound.play(SystemSoundType.alert);
      HapticFeedback.heavyImpact();
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown == 0) {
        t.cancel();
        widget.onReject();
      } else {
        setState(() => _countdown--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ringTimer?.cancel();
    _ringCtrl.dispose();
    super.dispose();
  }

  String _fmtScheduled(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${d.day}/${d.month} · $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final ride = widget.ride;
    final eta = ride.etaMinutes;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.fromLTRB(12, 24, 12, 20),
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 30)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
              decoration: const BoxDecoration(
                color: Color(0xFF1a1a2e),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  ScaleTransition(
                    scale: _ring,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.green.shade500,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withValues(alpha: 0.45),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.directions_car_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    t.incomingRideTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    t.incomingOfferSubtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                  ),
                  if (eta != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.green.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.navigation_rounded,
                                color: Colors.green.shade300,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                t.incomingReachPickup(eta),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  height: 1.15,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            t.incomingRideEtaHeadline(eta),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (ride.scheduledAt != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.event_rounded,
                              color: Colors.lightBlueAccent, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              t.incomingScheduledPickup(
                                _fmtScheduled(ride.scheduledAt!.toLocal()),
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        color: _countdown <= 5 ? Colors.red : Colors.white70,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        t.incomingRideSec(_countdown),
                        style: TextStyle(
                          color: _countdown <= 5
                              ? Colors.red.shade300
                              : Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _countdown / 20,
                      backgroundColor: Colors.white24,
                      color: _countdown <= 5
                          ? Colors.red.shade400
                          : Colors.green.shade400,
                      minHeight: 5,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _stat(
                        Icons.payments_rounded,
                        ride,
                        t.incomingRideFare,
                        Colors.green,
                        isFare: true,
                      ),
                      Container(
                        width: 1,
                        height: 48,
                        color: Colors.grey.shade200,
                      ),
                      _stat(
                        Icons.straighten_rounded,
                        ride.estimatedDistanceKm != null
                            ? t.distanceKmUnit(
                                ride.estimatedDistanceKm!.toStringAsFixed(1),
                              )
                            : '—',
                        t.incomingRideDistance,
                        Colors.blue,
                      ),
                      Container(
                        width: 1,
                        height: 48,
                        color: Colors.grey.shade200,
                      ),
                      _stat(
                        Icons.schedule_rounded,
                        eta != null ? '$eta ${t.minutesShort}' : '—',
                        t.incomingRideEta,
                        Colors.orange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  _locRow(
                    Icons.radio_button_checked_rounded,
                    Colors.green,
                    t.ridePickupLabel,
                    ride.pickupAddress ??
                        '${ride.pickupLat.toStringAsFixed(4)}, ${ride.pickupLng.toStringAsFixed(4)}',
                  ),
                  const SizedBox(height: 8),
                  _locRow(
                    Icons.location_on_rounded,
                    Colors.red,
                    t.rideDropoffLabel,
                    ride.dropoffAddress ??
                        '${ride.dropoffLat.toStringAsFixed(4)}, ${ride.dropoffLng.toStringAsFixed(4)}',
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: widget.onReject,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(
                              color: Colors.red,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            t.incomingRideDecline,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: widget.onAccept,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 4,
                            shadowColor: Colors.green.withValues(alpha: 0.4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                t.incomingRideAccept,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(
    IconData icon,
    dynamic val,
    String label,
    Color c, {
    bool isFare = false,
  }) =>
      Column(
        children: [
          Icon(icon, color: c, size: 22),
          const SizedBox(height: 6),
          if (isFare && val is DriverRideModel)
            FareWithPromo(
              ride: val,
              compact: true,
              alignment: CrossAxisAlignment.center,
              fareStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: c,
              ),
            )
          else
            Text(
              val.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: c,
              ),
            ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
        ],
      );

  Widget _locRow(IconData icon, Color c, String title, String sub) => Row(
        children: [
          Icon(icon, color: c, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                Text(
                  sub,
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      );
}
