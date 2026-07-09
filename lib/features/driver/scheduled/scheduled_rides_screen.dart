import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../l10n/app_localizations.dart';
import '../home/rides/model/ride_model.dart';
import '../home/rides/service/rides_service.dart';

class DriverScheduledRidesScreen extends StatefulWidget {
  const DriverScheduledRidesScreen({super.key});

  @override
  State<DriverScheduledRidesScreen> createState() =>
      _DriverScheduledRidesScreenState();
}

class _DriverScheduledRidesScreenState extends State<DriverScheduledRidesScreen> {
  bool _loading = true;
  List<DriverRideModel> _rides = [];
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
      final rides = await DriverRidesService.instance.getScheduledRides(
        lat: _pos?.latitude,
        lng: _pos?.longitude,
      );
      if (!mounted) return;
      setState(() {
        _rides = rides;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _fmtDate(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${d.day}/${d.month}/${d.year} · $h:$m';
  }

  String _minsUntil(DateTime? at) {
    if (at == null) return '—';
    final diff = at.difference(DateTime.now()).inMinutes;
    if (diff < 60) return '$diff';
    final h = diff ~/ 60;
    final m = diff % 60;
    return m > 0 ? '$h h $m m' : '$h h';
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

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
          : _rides.isEmpty
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
                    itemCount: _rides.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final ride = _rides[i];
                      return _ScheduledCard(
                        ride: ride,
                        whenLabel: ride.scheduledAt != null
                            ? _fmtDate(ride.scheduledAt!.toLocal())
                            : '—',
                        minsLabel: _minsUntil(ride.scheduledAt),
                        fareLabel: CurrencyUtils.formatSyp(ride.estimatedFare),
                        t: t,
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

  const _ScheduledCard({
    required this.ride,
    required this.whenLabel,
    required this.minsLabel,
    required this.fareLabel,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
