import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

class DriverFaqScreen extends StatelessWidget {
  const DriverFaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(local.driverFaq), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            local.driverFaqTitle,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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

          // ===== FAQ ITEMS =====
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
      ),
    );
  }

  // ===== SINGLE FAQ ITEM =====
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
