import 'package:flutter/material.dart';
import '../../../core/services/driver_balance_service.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../l10n/app_localizations.dart';

class DriverWalletScreen extends StatefulWidget {
  const DriverWalletScreen({super.key});

  @override
  State<DriverWalletScreen> createState() => _DriverWalletScreenState();
}

class _DriverWalletScreenState extends State<DriverWalletScreen> {
  double _balance = 0;
  List<Map<String, dynamic>> _payouts = [];
  bool _loading = true;
  final _amountCtrl = TextEditingController();

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final bal = await DriverBalanceService.instance.getBalance();
    final payouts = await DriverBalanceService.instance.getPayouts();
    if (!mounted) return;
    setState(() {
      _balance = bal;
      _payouts = payouts;
      _loading = false;
    });
  }

  Future<void> _withdraw() async {
    final t = AppLocalizations.of(context)!;
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.walletInvalidAmount)),
      );
      return;
    }
    if (amount > _balance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.walletInsufficient)),
      );
      return;
    }

    try {
      await DriverBalanceService.instance.requestPayout(amount);
      _amountCtrl.clear();
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.walletPayoutRequested),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.walletTitle),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade700, Colors.green.shade500],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.walletAvailable,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          CurrencyUtils.formatSyp(_balance),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: t.walletWithdrawAmount,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _withdraw,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        t.walletRequestPayout,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    t.walletPayoutHistory,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_payouts.isEmpty)
                    Text(t.walletNoPayouts, style: TextStyle(color: Colors.grey[600]))
                  else
                    ..._payouts.map(
                      (p) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(
                            CurrencyUtils.formatSyp(
                              double.tryParse(p['amount']?.toString() ?? '0') ?? 0,
                            ),
                          ),
                          subtitle: Text(p['status']?.toString() ?? ''),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
