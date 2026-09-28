import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'prepaid_wallet_service.dart';
import 'prepaid_wallet_topup_screen.dart';

class PrepaidWalletScreen extends StatefulWidget {
  const PrepaidWalletScreen({super.key});

  @override
  State<PrepaidWalletScreen> createState() => _PrepaidWalletScreenState();
}

class _PrepaidWalletScreenState extends State<PrepaidWalletScreen> {
  double _balance = 0;
  final String _currencySymbol = 'ل.س';
  List<Map<String, dynamic>> _requests = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);

    final results = await Future.wait([
      DriverPrepaidWalletService.instance.getBalance(),
      DriverPrepaidWalletService.instance.getMyTopupRequests(),
    ]);

    if (!mounted) return;
    final balanceData = results[0] as Map<String, dynamic>?;
    final requests = results[1] as List<Map<String, dynamic>>;
    setState(() {
      _balance = _num(balanceData?['balance']);
      _requests = requests;
      _loading = false;
    });
  }

  double _num(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  String _fmtMoney(double v) =>
      '${v.toStringAsFixed(0)} $_currencySymbol';

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final canGoOnline = _balance > 0;

    return Scaffold(
      backgroundColor: const Color(0xfff6f7fb),
      appBar: AppBar(
        title: Text(local.prepaidBalanceTitle),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : RefreshIndicator(
              color: Colors.green,
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (!canGoOnline)
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
                          Icon(Icons.warning_amber_rounded,
                              color: Colors.red.shade700),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              local.prepaidMustTopUp,
                              style: TextStyle(
                                  color: Colors.red.shade800, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),

                  _buildHeroCard(local),

                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            color: Colors.green),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            local.prepaidCommissionNote,
                            style: const TextStyle(
                                color: Colors.black87, fontSize: 12.5),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  Text(
                    local.prepaidRecentRequests,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  if (_requests.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        local.prepaidNoRequests,
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    )
                  else
                    ..._requests.map(_requestTile),

                  const SizedBox(height: 80),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PrepaidWalletTopupScreen()),
          );
          _load();
        },
        backgroundColor: Colors.black,
        icon: const Icon(Icons.add_card_rounded, color: Colors.white),
        label: Text(
          local.prepaidTopUp,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildHeroCard(AppLocalizations local) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0f2027), Color(0xFF203a43), Color(0xFF2c5364)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withOpacity(.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.account_balance_wallet_rounded,
                    color: Color(0xFFD4AF37), size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                local.prepaidCurrentBalance,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            _fmtMoney(_balance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.w900,
              letterSpacing: .5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _requestTile(Map<String, dynamic> r) {
    final local = AppLocalizations.of(context)!;
    final amount = _num(r['amount']);
    final method = r['method']?.toString() ?? '';
    final status = r['status']?.toString() ?? 'pending';

    Color color;
    IconData icon;
    String label;
    switch (status) {
      case 'approved':
        color = Colors.green;
        icon = Icons.check_circle_rounded;
        label = local.prepaidStatusApproved;
        break;
      case 'rejected':
        color = Colors.red;
        icon = Icons.cancel_rounded;
        label = local.prepaidStatusRejected;
        break;
      default:
        color = Colors.orange;
        icon = Icons.hourglass_top_rounded;
        label = local.prepaidStatusPending;
    }

    final methodLabel = method == 'bank' ? local.bankTransfer : local.cash;

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
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_fmtMoney(amount),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  '$methodLabel · $label',
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
