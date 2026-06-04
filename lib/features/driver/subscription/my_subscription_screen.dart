import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'subscription_plan_screen.dart';
import 'subscription_service.dart';

class MySubscriptionScreen extends StatefulWidget {
  const MySubscriptionScreen({super.key});

  @override
  State<MySubscriptionScreen> createState() => _MySubscriptionScreenState();
}

class _MySubscriptionScreenState extends State<MySubscriptionScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final data = await DriverSubscriptionService.instance.getMySubscription();
      if (mounted) setState(() => _data = data);
    } catch (_) {
      if (mounted) setState(() => _data = null);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  double _num(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  String _fmtMoney(double v) {
    final sym = _data?['currencySymbol']?.toString() ?? 'ل.س';
    return '${v.toStringAsFixed(0)} $sym';
  }

  Map<String, dynamic>? get _payInfo =>
      _data?['paymentInstructions'] as Map<String, dynamic>?;

  Future<void> _submitPayment() async {
    if (_data == null) return;
    final local = AppLocalizations.of(context)!;
    final balance = _num(_data!['balance']);
    final method = _data!['paymentMethod']?.toString() ?? 'sham_cash';

    final refCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    final amountCtrl = TextEditingController(
      text: balance > 0 ? balance.toStringAsFixed(0) : '',
    );

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Submit Payment'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: local.amount),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: refCtrl,
                decoration: InputDecoration(labelText: local.ref),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: noteCtrl,
                decoration: const InputDecoration(labelText: 'Note'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(local.no),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(local.yes),
          ),
        ],
      ),
    );

    if (ok != true || !mounted) return;

    final amount = double.tryParse(amountCtrl.text.trim());
    if (amount == null || amount <= 0) return;

    final submitted = await DriverSubscriptionService.instance.submitPayment(
      amount: amount,
      method: method,
      reference: refCtrl.text.trim(),
      note: noteCtrl.text.trim(),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          submitted
              ? 'Payment submitted — admin will review'
              : local.subscriptionFailed,
        ),
        backgroundColor: submitted ? Colors.green : Colors.red,
      ),
    );
    if (submitted) _load();
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(local.mySubscriptionTitle),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.green),
        ),
      );
    }

    if (_data == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(local.mySubscriptionTitle),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(local.noSubscriptionFound),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const SubscriptionPlanScreen(fromOnboarding: false),
                  ),
                ),
                child: Text(local.choosePlan),
              ),
            ],
          ),
        ),
      );
    }

    final balance = _num(_data!['balance']);
    final isOverdue = _data!['isOverdue'] == true;
    final canDrive = _data!['canDrive'] != false;
    final status = _data!['status']?.toString() ?? 'active';
    final plan = _data!['planType']?.toString() ?? 'commission';
    final commission = _num(_data!['commissionPercent']);
    final monthlyFee = _num(_data!['monthlyFee']);
    final driverId = _data!['driverId']?.toString() ?? '';
    final payMethod = _data!['paymentMethod']?.toString() ?? 'cash';
    final pending = (_data!['pendingPayments'] as List?) ?? [];
    final payments = (_data!['payments'] as List?) ?? [];
    final info = _payInfo;

    Color statusColor = Colors.green;
    String statusLabel = local.active;
    if (status == 'suspended') {
      statusColor = Colors.red;
      statusLabel = 'Suspended';
    } else if (status == 'pending_payment' || isOverdue) {
      statusColor = Colors.orange;
      statusLabel = local.paymentOverdue;
    }

    return Scaffold(
      backgroundColor: const Color(0xfff6f7fb),
      appBar: AppBar(
        title: Text(local.mySubscriptionTitle),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const SubscriptionPlanScreen(fromOnboarding: false),
              ),
            ),
            child: Text(local.changePlan, style: const TextStyle(color: Colors.green)),
          ),
        ],
      ),
      floatingActionButton: balance > 0 || status == 'pending_payment'
          ? FloatingActionButton.extended(
              onPressed: _submitPayment,
              backgroundColor: Colors.black,
              icon: const Icon(Icons.upload_rounded, color: Colors.white),
              label: Text(
                'Submit Payment',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          : null,
      body: RefreshIndicator(
        color: Colors.green,
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (!canDrive)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'You cannot go online until payment is confirmed.',
                        style: TextStyle(color: Colors.red.shade800, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isOverdue || status == 'suspended'
                      ? [Colors.red.shade600, Colors.red.shade800]
                      : [const Color(0xFF1a1a2e), const Color(0xFF16213e)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan == 'commission' ? local.commissionPlan : local.monthlyPlan,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(statusLabel, style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(.25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      plan == 'commission'
                          ? '${commission.toStringAsFixed(0)}%'
                          : _fmtMoney(monthlyFee),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _card(
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(local.amountDue, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(
                        _fmtMoney(balance),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: balance > 0 ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _statRow(local.totalEarned, _fmtMoney(_num(_data!['totalEarned']))),
                  _statRow(local.totalOwed, _fmtMoney(_num(_data!['totalOwed']))),
                  _statRow(local.totalPaid, _fmtMoney(_num(_data!['totalPaid']))),
                  if (_data!['nextDueAt'] != null)
                    _statRow(local.nextDue, _fmtDate(_data!['nextDueAt'])),
                ],
              ),
            ),

            if (pending.isNotEmpty) ...[
              Text('Pending Review', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...pending.map((p) => _paymentTile(p, pending: true)),
              const SizedBox(height: 16),
            ],

            _card(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(local.howToPay, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 14),
                  _payMethod(local.cashKey, Icons.payments_rounded, Colors.green, local.cash, local.payWeeklyInPerson, payMethod),
                  _payMethod(
                    local.shamCashKey,
                    Icons.phone_android_rounded,
                    Colors.purple,
                    local.shamCash,
                    '${local.transferTo}: ${info?['shamCashPhone'] ?? '—'}\n${local.ref}: DRV-$driverId',
                    payMethod,
                  ),
                  _payMethod(
                    local.balanceKey,
                    Icons.account_balance_wallet,
                    Colors.orange,
                    local.mobileBalance,
                    '${local.transferTo}: ${info?['balancePhone'] ?? '—'}',
                    payMethod,
                  ),
                  _payMethod(
                    local.bankKey,
                    Icons.account_balance_rounded,
                    Colors.blue,
                    local.bankTransfer,
                    '${info?['bankName'] ?? local.bankName}\n${local.account}: ${info?['bankAccount'] ?? '—'}\n${local.iban}: ${info?['bankIban'] ?? '—'}',
                    payMethod,
                  ),
                ],
              ),
            ),

            if (payments.isNotEmpty) ...[
              Text(local.paymentHistory, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              ...payments.map((p) => _paymentTile(p)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _card(Widget child) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: child,
      );

  Widget _statRow(String l, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l, style: TextStyle(color: Colors.grey[600])),
            Text(v, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      );

  Widget _payMethod(String key, IconData icon, Color color, String title, String info, String selected) {
    final sel = selected == key;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: sel ? color.withOpacity(.05) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: sel ? color.withOpacity(.3) : Colors.transparent),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(info, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
              ],
            ),
          ),
          if (sel)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
              child: Text(
                AppLocalizations.of(context)!.myMethod,
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Widget _paymentTile(dynamic p, {bool pending = false}) {
    final amount = _num(p['amount']);
    final method = (p['method']?.toString() ?? '').replaceAll('_', ' ').toUpperCase();
    final st = p['status']?.toString() ?? (pending ? 'pending' : 'approved');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Icon(
            st == 'approved' ? Icons.check_circle_rounded : Icons.hourglass_top_rounded,
            color: st == 'approved' ? Colors.green : Colors.orange,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_fmtMoney(amount), style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('$method · $st', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
              ],
            ),
          ),
          Text(_fmtDate(p['createdAt']), style: TextStyle(color: Colors.grey[400], fontSize: 11)),
        ],
      ),
    );
  }

  String _fmtDate(dynamic iso) {
    if (iso == null) return '—';
    try {
      final d = DateTime.parse(iso.toString()).toLocal();
      return '${d.day}/${d.month}/${d.year}';
    } catch (_) {
      return '—';
    }
  }
}
