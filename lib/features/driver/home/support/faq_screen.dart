import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../content/content_service.dart';

class DriverFaqScreen extends StatefulWidget {
  const DriverFaqScreen({super.key});

  @override
  State<DriverFaqScreen> createState() => _DriverFaqScreenState();
}

class _DriverFaqScreenState extends State<DriverFaqScreen> {
  List<ContentFaqItem> _remote = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final items = await ContentService.instance.fetchFaq(audience: 'driver');
      if (mounted) setState(() => _remote = items);
    } catch (_) {
      /* fallback */
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(title: Text(local.driverFaq), centerTitle: true),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  local.driverFaqTitle,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  local.driverFaqSubtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 24),
                if (_remote.isNotEmpty)
                  ..._remote.map(
                    (item) => _faqItem(
                      icon: Icons.help_outline_rounded,
                      question: item.question(isAr),
                      answer: item.answer(isAr),
                    ),
                  )
                else ...[
                  _faqItem(
                    icon: Icons.directions_car,
                    question: local.driverFaqVehicleUpdateQ,
                    answer: local.driverFaqVehicleUpdateA,
                  ),
                  _faqItem(
                    icon: Icons.schedule,
                    question: local.driverFaqScheduleQ,
                    answer: local.driverFaqScheduleA,
                  ),
                  _faqItem(
                    icon: Icons.payment,
                    question: local.driverFaqPaymentQ,
                    answer: local.driverFaqPaymentA,
                  ),
                  _faqItem(
                    icon: Icons.security,
                    question: local.driverFaqSafetyQ,
                    answer: local.driverFaqSafetyA,
                  ),
                  _faqItem(
                    icon: Icons.support_agent,
                    question: local.driverFaqSupportQ,
                    answer: local.driverFaqSupportA,
                  ),
                  _faqItem(
                    icon: Icons.cancel_outlined,
                    question: local.driverFaqTripCancelQ,
                    answer: local.driverFaqTripCancelA,
                  ),
                ],
              ],
            ),
    );
  }

  Widget _faqItem({
    required IconData icon,
    required String question,
    required String answer,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ExpansionTile(
        leading: Icon(icon, color: Colors.green.shade700),
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        children: [
          Text(
            answer,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
