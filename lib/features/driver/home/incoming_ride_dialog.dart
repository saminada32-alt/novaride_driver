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

    HapticFeedback.vibrate();

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
    _ringCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final ride = widget.ride;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 30)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF1a1a2e),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  ScaleTransition(
                    scale: _ring,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.green.shade500,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.directions_car_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    t.incomingRideTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
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
                      minHeight: 4,
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
                        Icons.attach_money_rounded,
                        ride,
                        t.incomingRideFare,
                        Colors.green,
                        isFare: true,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey.shade200,
                      ),
                      _stat(
                        Icons.straighten_rounded,
                        '${ride.estimatedDistanceKm?.toStringAsFixed(1) ?? '-'} ${t.km}',
                        t.incomingRideDistance,
                        Colors.blue,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey.shade200,
                      ),
                      _stat(
                        Icons.schedule_rounded,
                        '${ride.etaMinutes ?? '-'} min',
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
                            padding: const EdgeInsets.symmetric(vertical: 14),
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
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 4,
                            shadowColor: Colors.green.withOpacity(.4),
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
      Icon(icon, color: c, size: 20),
      const SizedBox(height: 4),
      if (isFare && val is DriverRideModel)
        FareWithPromo(
          ride: val,
          compact: true,
          alignment: CrossAxisAlignment.center,
          fareStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: c),
        )
      else
        Text(
          val.toString(),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: c),
        ),
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
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
            Text(
              sub,
              style: TextStyle(color: Colors.grey[500], fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ],
  );
}
