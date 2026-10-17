import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../l10n/app_localizations.dart';
import 'prepaid_wallet_service.dart';

enum _TopupMethod { shamCash, bank, cash }

class PrepaidWalletTopupScreen extends StatefulWidget {
  const PrepaidWalletTopupScreen({super.key});

  @override
  State<PrepaidWalletTopupScreen> createState() => _PrepaidWalletTopupScreenState();
}

class _PrepaidWalletTopupScreenState extends State<PrepaidWalletTopupScreen> {
  Map<String, dynamic>? _instructions;
  bool _loading = true;
  bool _submitting = false;
  File? _receipt;
  final _picker = ImagePicker();
  _TopupMethod _method = _TopupMethod.shamCash;

  final amountController = TextEditingController();
  final referenceController = TextEditingController();
  final noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    amountController.dispose();
    referenceController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await DriverPrepaidWalletService.instance.getTopupInstructions();
    if (!mounted) return;
    setState(() {
      _instructions = data;
      _loading = false;
    });
  }

  void _copy(String value, AppLocalizations local) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(local.prepaidCopied), duration: const Duration(seconds: 1)),
    );
  }

  Future<void> _pickReceipt() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1600,
      maxHeight: 1600,
    );
    if (picked == null || !mounted) return;
    setState(() => _receipt = File(picked.path));
  }

  String get _methodKey => switch (_method) {
        _TopupMethod.shamCash => 'sham_cash',
        _TopupMethod.bank => 'bank',
        _TopupMethod.cash => 'cash',
      };

  Future<void> _submit() async {
    final local = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final amount = double.tryParse(amountController.text.trim());
    if (amount == null || amount <= 0) return;

    final needsReceipt = _method == _TopupMethod.shamCash;
    if (needsReceipt && _receipt == null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(local.prepaidReceiptRequired),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    final result = await DriverPrepaidWalletService.instance.submitTopupRequest(
      amount: amount,
      method: _methodKey,
      reference: referenceController.text.trim(),
      note: noteController.text.trim(),
      receipt: needsReceipt ? _receipt : null,
    );
    if (!mounted) return;
    setState(() => _submitting = false);

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          result.ok
              ? local.prepaidRequestSubmitted
              : result.isDuplicateReceipt
                  ? local.prepaidReceiptDuplicate
                  : local.prepaidRequestFailed,
        ),
        backgroundColor: result.ok ? Colors.green : Colors.red,
      ),
    );
    if (result.ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xfff6f7fb),
      appBar: AppBar(
        title: Text(local.prepaidTopUp),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  local.prepaidChooseMethod,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 14),
                _methodSelector(),
                const SizedBox(height: 20),
                switch (_method) {
                  _TopupMethod.shamCash => _shamCashPanel(local),
                  _TopupMethod.bank => _bankPanel(local),
                  _TopupMethod.cash => _cashPanel(local),
                },
              ],
            ),
    );
  }

  Widget _methodSelector() {
    final local = AppLocalizations.of(context)!;
    final options = [
      (_TopupMethod.shamCash, local.shamCash, Icons.phone_android_rounded, Colors.purple),
      (_TopupMethod.bank, local.bankTransfer, Icons.account_balance_rounded, Colors.blue),
      (_TopupMethod.cash, local.cash, Icons.payments_rounded, Colors.green),
    ];

    return Row(
      children: options.map((o) {
        final (method, label, icon, color) = o;
        final selected = _method == method;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _method = method),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: selected ? color.withOpacity(.1) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected ? color : Colors.black12,
                  width: selected ? 1.6 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(icon, color: color, size: 22),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                      color: selected ? color : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _card(Widget child) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: child,
      );

  Widget _copyRow(String label, String value, AppLocalizations local) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _copy(value, local),
            icon: const Icon(Icons.copy_rounded, size: 20, color: Colors.green),
            tooltip: local.prepaidCopyReference,
          ),
        ],
      ),
    );
  }

  Widget _shamCashPanel(AppLocalizations local) {
    final sc = _instructions?['shamCash'] as Map<String, dynamic>? ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.phone_android_rounded, color: Colors.purple, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      local.prepaidShamCashNote,
                      style: const TextStyle(color: Colors.black87, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const Divider(height: 28),
              _copyRow(local.transferTo, sc['phone']?.toString() ?? '—', local),
              _copyRow(local.account, sc['accountName']?.toString() ?? '—', local),
              _copyRow(local.ref, sc['reference']?.toString() ?? '—', local),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _requestForm(local, referenceLabel: null, withReceipt: true),
      ],
    );
  }

  Widget _bankPanel(AppLocalizations local) {
    final bank = _instructions?['bank'] as Map<String, dynamic>? ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.account_balance_rounded, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      local.prepaidBankNote,
                      style: const TextStyle(color: Colors.black87, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const Divider(height: 28),
              _copyRow(local.bankName, bank['bankName']?.toString() ?? '—', local),
              _copyRow(local.account, bank['accountName']?.toString() ?? '—', local),
              _copyRow(local.iban, bank['accountNumber']?.toString() ?? '—', local),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _requestForm(local, referenceLabel: local.ref),
      ],
    );
  }

  Widget _cashPanel(AppLocalizations local) {
    final cash = _instructions?['cash'] as Map<String, dynamic>? ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.store_rounded, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      local.prepaidCashNote,
                      style: const TextStyle(color: Colors.black87, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const Divider(height: 28),
              Text(local.prepaidOfficeAddress, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              Text(
                cash['officeAddress']?.toString() ?? '—',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _requestForm(local, referenceLabel: null),
      ],
    );
  }

  Widget _receiptPicker(AppLocalizations local) {
    final file = _receipt;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(local.prepaidReceiptTitle,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 4),
        Text(local.prepaidReceiptHint,
            style: TextStyle(color: Colors.grey[600], fontSize: 11.5)),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _submitting ? null : _pickReceipt,
          child: Container(
            width: double.infinity,
            height: file == null ? 96 : 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: file == null ? Colors.black26 : Colors.green,
                width: file == null ? 1 : 1.6,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: file == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_photo_alternate_rounded,
                          size: 30, color: Colors.green),
                      const SizedBox(height: 6),
                      Text(local.prepaidPickReceipt,
                          style: const TextStyle(fontSize: 13)),
                    ],
                  )
                : Image.file(file, fit: BoxFit.cover),
          ),
        ),
        if (file != null)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: _submitting ? null : _pickReceipt,
              icon: const Icon(Icons.swap_horiz_rounded, size: 18),
              label: Text(local.prepaidChangeReceipt),
            ),
          ),
      ],
    );
  }

  Widget _requestForm(
    AppLocalizations local, {
    String? referenceLabel,
    bool withReceipt = false,
  }) {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(local.prepaidSubmitRequest,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 14),
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: withReceipt ? local.prepaidAmountTransferred : local.amount,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          if (withReceipt) ...[
            const SizedBox(height: 14),
            _receiptPicker(local),
          ],
          if (referenceLabel != null) ...[
            const SizedBox(height: 10),
            TextField(
              controller: referenceController,
              decoration: InputDecoration(
                labelText: referenceLabel,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
          const SizedBox(height: 10),
          TextField(
            controller: noteController,
            decoration: InputDecoration(
              labelText: local.paymentNote,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      local.prepaidSubmitRequest,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
