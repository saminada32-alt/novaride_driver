import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../driver/home/home_screen.dart';
import 'subscription_service.dart';

class SubscriptionPlanScreen extends StatefulWidget {
  final bool fromOnboarding;
  const SubscriptionPlanScreen({super.key, this.fromOnboarding = true});

  @override
  State<SubscriptionPlanScreen> createState() => _SubscriptionPlanScreenState();
}

class _SubscriptionPlanScreenState extends State<SubscriptionPlanScreen> {
  String _plan = 'commission';
  String _payMethod = 'sham_cash';
  bool _loading = false;
  bool _loadingPlans = false;
  double _commission = 10;
  double _monthlyFee = 150000;
  Map<String, dynamic>? _payInfo;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    try {
      final data = await DriverSubscriptionService.instance.getPlans();
      if (!mounted) return;

      final plans = data?['plans'] as List? ?? [];
      for (final p in plans) {
        if (p is! Map) continue;
        final m = Map<String, dynamic>.from(p);
        if (m['planType'] == 'commission') {
          _commission = (m['commissionPercent'] as num?)?.toDouble() ?? 10;
        }
        if (m['planType'] == 'monthly') {
          _monthlyFee = (m['monthlyFee'] as num?)?.toDouble() ?? 150000;
        }
      }
      _payInfo = data?['paymentInstructions'] as Map<String, dynamic>?;
    } catch (_) {
      // defaults already set
    } finally {
      if (mounted) setState(() => _loadingPlans = false);
    }
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    final ok = await DriverSubscriptionService.instance.choosePlan(
      planType: _plan,
      paymentMethod: _payMethod,
    );
    setState(() => _loading = false);

    if (!mounted) return;
    final local = AppLocalizations.of(context)!;

    if (ok) {
      if (widget.fromOnboarding) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const DriverHomeScreen()),
          (_) => false,
        );
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(local.subscriptionUpdated),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(local.subscriptionFailed),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _payHint(String key) {
    final info = _payInfo;
    final local = AppLocalizations.of(context)!;
    switch (key) {
      case 'sham_cash':
        return '${local.transferTo}: ${info?['shamCashPhone'] ?? '—'}';
      case 'balance':
        return '${local.transferTo}: ${info?['balancePhone'] ?? '—'}';
      case 'bank':
        return '${info?['bankName'] ?? local.bankName}\n${local.iban}: ${info?['bankIban'] ?? '—'}';
      default:
        return local.payWeeklyInPerson;
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xfff6f7fb),
      appBar: AppBar(
        title: Text(local.chooseYourPlan),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: !widget.fromOnboarding,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 44),
                  const SizedBox(height: 12),
                  Text(
                    local.novaRidePartnership,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(local.chooseHowYouWork, style: TextStyle(color: Colors.white.withOpacity(.7))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _planCard('commission', Icons.percent_rounded, local.commission, local.payPerRide, Colors.green),
                const SizedBox(width: 12),
                _planCard('monthly', Icons.calendar_month_rounded, local.monthly, local.fixedFee, Colors.blue),
              ],
            ),
            const SizedBox(height: 20),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _plan == 'commission'
                  ? _detailCard(
                      local.commissionPlan,
                      '${_commission.toInt()}%',
                      local.commissionExplanation,
                      Colors.green,
                    )
                  : _detailCard(
                      local.monthlyPlan,
                      '${_monthlyFee.toInt()} ${local.currencyShort}',
                      local.monthlyExplanation,
                      Colors.blue,
                    ),
            ),
            const SizedBox(height: 20),
            _section(
              local.paymentMethodTitle,
              Column(
                children: [
                  _paymentOption('cash', Icons.payments_rounded, local.cash),
                  _paymentOption('sham_cash', Icons.phone_android_rounded, local.shamCash),
                  _paymentOption('balance', Icons.account_balance_wallet, local.mobileBalance),
                  _paymentOption('bank', Icons.account_balance_rounded, local.bankTransfer),
                ],
              ),
            ),
            if (_plan == 'monthly')
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange.shade800, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'First monthly payment required before going online.',
                          style: TextStyle(color: Colors.orange.shade900, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _loading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        widget.fromOnboarding ? local.startDriving : local.updatePlan,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _planCard(String type, IconData icon, String title, String subtitle, Color color) {
    final sel = _plan == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _plan = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: sel ? color : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: sel ? color : Colors.grey.shade200, width: sel ? 2 : 1),
          ),
          child: Column(
            children: [
              Icon(icon, color: sel ? Colors.white : color, size: 32),
              const SizedBox(height: 8),
              Text(title, style: TextStyle(color: sel ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
              Text(subtitle, style: TextStyle(color: sel ? Colors.white70 : Colors.grey[600], fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailCard(String title, String value, String info, Color color) => _section(
        title,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 8),
            Text(info, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      );

  Widget _section(String title, Widget child) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
            ),
            child: child,
          ),
          const SizedBox(height: 16),
        ],
      );

  Widget _paymentOption(String key, IconData icon, String title) => GestureDetector(
        onTap: () => setState(() => _payMethod = key),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _payMethod == key ? Colors.black : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _payMethod == key ? Colors.black : Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Icon(icon, color: _payMethod == key ? Colors.white : Colors.black54, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _payMethod == key ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      _payHint(key),
                      style: TextStyle(fontSize: 11, color: _payMethod == key ? Colors.white60 : Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
