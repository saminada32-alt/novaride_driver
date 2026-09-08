import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../l10n/app_localizations.dart';
import '../home/rides/model/ride_model.dart';
import '../home/rides/service/rides_service.dart';

/// Ride IDs the driver dismissed from their "nearby scheduled" preview.
/// These rides are never assigned to a specific driver ahead of time (see
/// RidesService.getUpcomingScheduledForDriver on the backend — it's just a
/// heads-up list), so there's nothing to cancel server-side; this only
/// hides the card locally so it stops showing up for this driver.
class _HiddenScheduledRides {
  static const _key = 'driver_hidden_scheduled_ride_ids';

  static Future<Set<int>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? const [];
    return list.map(int.parse).toSet();
  }

  static Future<void> hide(int rideId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = await load();
    ids.add(rideId);
    await prefs.setStringList(_key, ids.map((e) => e.toString()).toList());
  }
}

class DriverScheduledRidesScreen extends StatefulWidget {
  const DriverScheduledRidesScreen({super.key});

  @override
  State<DriverScheduledRidesScreen> createState() =>
      _DriverScheduledRidesScreenState();
}

class _DriverScheduledRidesScreenState extends State<DriverScheduledRidesScreen> {
  bool _loading = true;
  List<DriverRideModel> _rides = [];
  Set<int> _hiddenIds = {};
  LatLng? _pos;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final loc = Location();
      final perm = await loc.requestPermission();
      if (perm == PermissionStatus.granted) {
        final data = await loc.getLocation();
        if (data.latitude != null) {
          _pos = LatLng(data.latitude!, data.longitude!);
        }
      }
      final results = await Future.wait([
        DriverRidesService.instance.getScheduledRides(
          lat: _pos?.latitude,
          lng: _pos?.longitude,
        ),
        _HiddenScheduledRides.load(),
      ]);
      if (!mounted) return;
      setState(() {
        _rides = results[0] as List<DriverRideModel>;
        _hiddenIds = results[1] as Set<int>;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _hideRide(int rideId) async {
    await _HiddenScheduledRides.hide(rideId);
    if (!mounted) return;
    setState(() => _hiddenIds = {..._hiddenIds, rideId});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.scheduledRideHidden)),
    );
  }

  String _fmtDate(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${d.day}/${d.month}/${d.year} · $h:$m';
  }

  String _minsUntil(DateTime? at, AppLocalizations t) {
    if (at == null) return '—';
    final diff = at.difference(DateTime.now()).inMinutes;
    if (diff < 60) return '$diff';
    final h = diff ~/ 60;
    final m = diff % 60;
    return m > 0
        ? '$h ${t.hoursShort} $m ${t.minutesShort}'
        : '$h ${t.hoursShort}';
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final visibleRides =
        _rides.where((r) => !_hiddenIds.contains(r.id)).toList();

    return Scaffold(
      backgroundColor: const Color(0xfff6f7fb),
      appBar: AppBar(
        title: Text(t.scheduledRidesTitle),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : visibleRides.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.event_busy_rounded,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          t.scheduledRidesEmpty,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          t.scheduledRidesEmptyHint,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: visibleRides.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final ride = visibleRides[i];
                      return _ScheduledCard(
                        ride: ride,
                        whenLabel: ride.scheduledAt != null
                            ? _fmtDate(ride.scheduledAt!.toLocal())
                            : '—',
                        minsLabel: _minsUntil(ride.scheduledAt, t),
                        fareLabel: CurrencyUtils.formatSyp(ride.estimatedFare),
                        t: t,
                        onHide: () => _hideRide(ride.id),
                      );
                    },
                  ),
                ),
    );
  }
}

class _ScheduledCard extends StatelessWidget {
  final DriverRideModel ride;
  final String whenLabel;
  final String minsLabel;
  final String fareLabel;
  final AppLocalizations t;
  final VoidCallback onHide;

  const _ScheduledCard({
    required this.ride,
    required this.whenLabel,
    required this.minsLabel,
    required this.fareLabel,
    required this.t,
    required this.onHide,
  });

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _ScheduledRideDetailsSheet(
        ride: ride,
        whenLabel: whenLabel,
        minsLabel: minsLabel,
        fareLabel: fareLabel,
        t: t,
        onHide: onHide,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _showDetails(context),
        child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.schedule_rounded,
                        size: 14, color: Colors.blue.shade700),
                    const SizedBox(width: 4),
                    Text(
                      t.scheduledRideBadge,
                      style: TextStyle(
                        color: Colors.blue.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                fareLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            whenLabel,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            t.scheduledRideStartsIn(minsLabel),
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          const SizedBox(height: 12),
          _row(Icons.radio_button_checked_rounded, Colors.green,
              ride.pickupAddress ?? t.ridePickupLabel),
          const SizedBox(height: 6),
          _row(Icons.location_on_rounded, Colors.red,
              ride.dropoffAddress ?? t.rideDropoffLabel),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              t.scheduledRideDriverHint,
              style: TextStyle(
                color: Colors.orange.shade900,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
        ),
      ),
    );
  }

  Widget _row(IconData icon, Color color, String text) => Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      );
}

/// Read-only details view for an unassigned nearby scheduled ride.
/// There's nothing here for a driver to edit or cancel — this ride isn't
/// assigned to anyone yet; the driver only gets an accept offer close to
/// pickup time (see t.scheduledRideDriverHint below).
class _ScheduledRideDetailsSheet extends StatelessWidget {
  final DriverRideModel ride;
  final String whenLabel;
  final String minsLabel;
  final String fareLabel;
  final AppLocalizations t;
  final VoidCallback onHide;

  const _ScheduledRideDetailsSheet({
    required this.ride,
    required this.whenLabel,
    required this.minsLabel,
    required this.fareLabel,
    required this.t,
    required this.onHide,
  });

  Future<void> _confirmHide(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.scheduledRideHideConfirmTitle),
        content: Text(t.scheduledRideHideConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(t.scheduledRideHide),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    onHide();
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
                    t.rideNumber(ride.id),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  fareLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              whenLabel,
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
            Text(
              t.scheduledRideStartsIn(minsLabel),
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            const SizedBox(height: 20),
            _row(Icons.radio_button_checked_rounded, Colors.green,
                ride.pickupAddress ?? t.ridePickupLabel),
            if (ride.hasMultiStop) ...[
              const SizedBox(height: 8),
              for (var i = 0; i < ride.waypoints.length; i++) ...[
                _row(
                  Icons.circle,
                  Colors.grey,
                  '${t.multiStopLabel} ${i + 1}: '
                  '${ride.waypoints[i].address ?? "—"}',
                ),
                const SizedBox(height: 8),
              ],
            ] else
              const SizedBox(height: 8),
            _row(Icons.location_on_rounded, Colors.red,
                ride.dropoffAddress ?? t.rideDropoffLabel),
            if (ride.estimatedDistanceKm != null) ...[
              const SizedBox(height: 12),
              _row(
                Icons.straighten_rounded,
                Colors.blueGrey,
                t.distanceKmUnit(ride.estimatedDistanceKm!.toStringAsFixed(1)),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                t.scheduledRideDriverHint,
                style: TextStyle(
                  color: Colors.orange.shade900,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _confirmHide(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: BorderSide(color: Colors.red.shade200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.visibility_off_outlined, size: 18),
                label: Text(t.scheduledRideHide),
              ),
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
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13)),
          ),
        ],
      );
}
