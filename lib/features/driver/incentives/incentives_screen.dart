import 'package:flutter/material.dart';
import '../../../core/widgets/a11y.dart';
import '../../../core/widgets/empty_illustration.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../l10n/app_localizations.dart';
import 'incentives_service.dart';

class DriverIncentivesScreen extends StatefulWidget {
  const DriverIncentivesScreen({super.key});

  @override
  State<DriverIncentivesScreen> createState() => _DriverIncentivesScreenState();
}

class _DriverIncentivesScreenState extends State<DriverIncentivesScreen> {
  List<DriverIncentiveZone> _zones = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _zones = await DriverIncentivesService.instance.fetchActive();
    } catch (_) {
      _zones = [];
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return A11yScreen(
      label: t.driverIncentivesTitle,
      child: Scaffold(
      appBar: AppBar(
        title: A11yHeader(
          label: t.driverIncentivesTitle,
          child: Text(t.driverIncentivesTitle),
        ),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : RefreshIndicator(
              onRefresh: _load,
              child: _zones.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.12,
                        ),
                        EmptyIllustration(
                          imageAsset: 'assets/images/Gift card-bro.png',
                          message: t.driverIncentivesEmpty,
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _zones.length,
                      itemBuilder: (_, i) {
                        final z = _zones[i];
                        final label = isAr ? z.labelAr : z.labelEn;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.local_fire_department,
                                        color: Colors.orange.shade700),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        label.isNotEmpty ? label : z.zoneCode,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${z.surgeMultiplier.toStringAsFixed(1)}x',
                                        style: TextStyle(
                                          color: Colors.orange.shade800,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ...z.incentives.map((inc) {
                                  final title = isAr
                                      ? inc['titleAr']?.toString()
                                      : inc['titleEn']?.toString();
                                  final bonus = double.tryParse(
                                        inc['bonusAmount']?.toString() ?? '0',
                                      ) ??
                                      0;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.card_giftcard,
                                            size: 18, color: Colors.green),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            title ?? t.driverIncentivesBonus,
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                        ),
                                        Text(
                                          '+${CurrencyUtils.formatSyp(bonus)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    ),
    );
  }
}
