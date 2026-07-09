import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/utils/currency_utils.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/providers/auth_provider.dart';
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
    final csv = buildEarningsCsv(e);
    await Share.share(csv, subject: t.exportStatement);
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
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
    );
  }

  String _fmtDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}
