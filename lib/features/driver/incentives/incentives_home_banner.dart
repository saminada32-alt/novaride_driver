import 'package:flutter/material.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../l10n/app_localizations.dart';
import 'incentives_screen.dart';
import 'incentives_service.dart';

/// Compact banner on the home map — tap to open full incentives screen.
class IncentivesHomeBanner extends StatefulWidget {
  const IncentivesHomeBanner({super.key});

  @override
  State<IncentivesHomeBanner> createState() => _IncentivesHomeBannerState();
}

class _IncentivesHomeBannerState extends State<IncentivesHomeBanner> {
  List<DriverIncentiveZone> _zones = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      _zones = await DriverIncentivesService.instance.fetchActive();
    } catch (_) {
      _zones = [];
    }
    if (mounted) setState(() => _loading = false);
  }

  int get _bonusCount =>
      _zones.fold<int>(0, (n, z) => n + z.incentives.length);

  double get _topBonus {
    var max = 0.0;
    for (final z in _zones) {
      for (final inc in z.incentives) {
        final v = double.tryParse(inc['bonusAmount']?.toString() ?? '0') ?? 0;
        if (v > max) max = v;
      }
    }
    return max;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _zones.isEmpty) return const SizedBox.shrink();

    final t = AppLocalizations.of(context)!;

    return Semantics(
      button: true,
      label: '${t.driverIncentivesTitle}. $_bonusCount ${t.driverIncentivesBonus}',
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DriverIncentivesScreen()),
        ),
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(14),
          color: Colors.orange.shade50,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Icon(Icons.local_fire_department, color: Colors.orange.shade800),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.driverIncentivesTitle,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.orange.shade900,
                        ),
                      ),
                      Text(
                        '$_bonusCount ${t.driverIncentivesActiveCount} · +${CurrencyUtils.formatSyp(_topBonus)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.orange.shade700),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
