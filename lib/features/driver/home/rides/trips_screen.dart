// lib/features/driver/trips/trips_page.dart
// lib/features/driver/trips/trips_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/a11y.dart';
import '../../../../core/widgets/fare_with_promo.dart';
import '../../../../l10n/app_localizations.dart';
import '../rides/model/ride_model.dart';
import 'provider/rides_provider.dart';
import 'screens/active_ride_ui.dart';

class TripsPage extends StatefulWidget {
  const TripsPage({super.key});
  @override
  State<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ← مو بدنا token كـ parameter بعد الآن
      context.read<RidesProvider>().loadTrips();
    });
  }

  Color _statusColor(DriverRideStatus s) {
    switch (s) {
      case DriverRideStatus.completed:
        return Colors.green;
      case DriverRideStatus.cancelled:
        return Colors.red;
      case DriverRideStatus.trip_started:
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  String _statusLabel(DriverRideStatus s, AppLocalizations t) =>
      ActiveRideUi.tripStatusLabel(s, t);

  String _formatDate(DateTime? d) {
    if (d == null) return '';
    final l = d.toLocal();
    return '${l.day}/${l.month}/${l.year}  '
        '${l.hour.toString().padLeft(2, '0')}:'
        '${l.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final provider = context.watch<RidesProvider>();

    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.green),
      );
    }

    return Column(
      children: [
        // ─── Filter Tabs ──────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              _tab(t.all, 'all', provider),
              _tab(t.completed, 'COMPLETED', provider),
              _tab(t.cancelled, 'CANCELLED', provider),
            ],
          ),
        ),

        // ─── List ─────────────────────────────────────────────
        Expanded(
          child: provider.trips.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // استبدلنا الأيقونة بصورة من الأصول
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: Image.asset(
                          'assets/images/confused.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.history,
                              size: 64,
                              color: Colors.grey,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        t.noTrips ?? 'No trips yet',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: Colors.green,
                  onRefresh: () => provider.loadTrips(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.trips.length,
                    itemBuilder: (_, i) {
                      final trip = provider.trips[i];
                      final color = _statusColor(trip.status);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 8),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: color.withOpacity(.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.directions_car,
                                color: color,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '#${trip.id}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      FareWithPromo(
                                        ride: trip,
                                        compact: true,
                                        alignment: CrossAxisAlignment.end,
                                        fareStyle: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: color,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        trip.estimatedDistanceKm != null
                                            ? '${trip.estimatedDistanceKm!.toStringAsFixed(1)} km'
                                            : '—',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: color.withOpacity(.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          _statusLabel(trip.status, t),
                                          style: TextStyle(
                                            color: color,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatDate(trip.createdAt),
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _tab(String label, String key, RidesProvider provider) {
    final sel = provider.filter == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => provider.applyFilter(key),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: sel ? Colors.green : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: sel ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
