import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/utils/currency_utils.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/providers/auth_provider.dart';
import '../rides/model/ride_model.dart';
import '../rides/screens/active_ride_ui.dart';
import '../rides/service/rides_service.dart';
import '../rides/widgets/trip_details_sheet.dart';
import 'earning_export.dart';
import 'model/earning_model.dart';
import 'provider/earning_provider.dart';

class EarningsPage extends StatefulWidget {
  const EarningsPage({super.key});

  @override
  State<EarningsPage> createState() => _EarningsPageState();
}

class _EarningsPageState extends State<EarningsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().token;
      if (token != null) {
        context.read<EarningProvider>().loadEarnings(token);
      }
    });
  }

  Future<void> _exportStatement(EarningModel e) async {
    final t = AppLocalizations.of(context)!;
    final csv = buildEarningsCsv(e, t);
    await Share.share(csv, subject: t.exportStatement);
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

  Future<void> _showRideDetails(RecentRide r) async {
    final t = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.green)),
    );

    DriverRideModel? full;
    try {
      // The earnings summary only carries id/amount/date — this app has no
      // single-ride-by-id endpoint, so we reuse the same ride-history call
      // the Trips tab uses and pick out the matching one.
      final rides = await DriverRidesService.instance.getMyRides();
      for (final ride in rides) {
        if (ride.id == r.rideId) {
          full = ride;
          break;
        }
      }
    } catch (_) {
      // fall through — full stays null, handled below
    }

    if (!mounted) return;
    Navigator.pop(context); // close the loading dialog

    if (full == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.genericLoadError)),
      );
      return;
    }

    final resolved = full;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => TripDetailsSheet(
        trip: resolved,
        statusColor: _statusColor(resolved.status),
        statusLabel: ActiveRideUi.tripStatusLabel(resolved.status, t),
        dateLabel: _fmtDate(resolved.createdAt ?? r.date),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final prov = context.watch<EarningProvider>();
    final auth = context.read<AuthProvider>();

    if (prov.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.green)),
      );
    }

    final e = prov.earning;

    if (e == null && prov.error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off_rounded, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text(
                  t.genericLoadError,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    final tok = auth.token;
                    if (tok != null) prov.loadEarnings(tok);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: Text(t.retry, style: const TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (e == null) {
      return Scaffold(body: Center(child: Text(t.noData)));
    }

    return Scaffold(
      backgroundColor: const Color(0xfff6f7fb),
      appBar: AppBar(
        title: Text(t.totalEarnings),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final tok = auth.token;
          if (tok != null) await prov.loadEarnings(tok);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xff1DBF73), Color(0xff17A964)],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Text(t.totalEarnings),
                  Text(
                    CurrencyUtils.formatSyp(e.total),
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('${e.trips} ${t.trips}'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _mini(t.daily, e.today, Colors.blue, t),
                const SizedBox(width: 8),
                _mini(t.weekly, e.week, Colors.purple, t),
                const SizedBox(width: 8),
                _mini(t.monthly, e.month, Colors.orange, t),
              ],
            ),
            const SizedBox(height: 20),
            if (prov.chartData.isNotEmpty) ...[
              Text(
                t.earningsBreakdown,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...prov.chartData.map((c) => _chartRow(c, prov.selectedTotal, t)),
            ],
            const SizedBox(height: 24),
            Text(
              t.recentTransactions,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...e.recentRides.map((r) => _rideItem(r, t)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _exportStatement(e),
                icon: const Icon(Icons.download_rounded),
                label: Text(t.exportStatement),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mini(String label, double val, Color c, AppLocalizations t) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: c.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(label, style: TextStyle(color: c)),
              Text(
                CurrencyUtils.formatSypCompact(val),
                style: TextStyle(fontWeight: FontWeight.bold, color: c),
              ),
            ],
          ),
        ),
      );

  Widget _chartRow(DailyEarning item, double total, AppLocalizations t) {
    final pct = total > 0 ? item.amount / total : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(width: 70, child: Text(item.label)),
          Expanded(
            child: LinearProgressIndicator(
              value: pct,
              color: Colors.green,
              backgroundColor: Colors.green.withValues(alpha: .2),
            ),
          ),
          const SizedBox(width: 10),
          Text(CurrencyUtils.formatSypCompact(item.amount)),
        ],
      ),
    );
  }

  Widget _rideItem(RecentRide r, AppLocalizations t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _showRideDetails(r),
          child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const Icon(Icons.directions_car, color: Colors.green),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.rideNumber(r.rideId),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  _fmtDate(r.date),
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            CurrencyUtils.formatSyp(r.amount),
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
          ),
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}
