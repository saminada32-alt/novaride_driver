import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:country_picker/country_picker.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/services/legal_service.dart';
import '../../legal/legal_document_screen.dart';
import '../../../core/utils/phone_utils.dart';
import '../providers/auth_provider.dart';
import '../otp/otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();

  String? _licenseCountry;
  String _code = '+963';
  bool _agreed = false;
  bool _loadingLegal = false;
  bool _sending = false;
  List<LegalDocumentView> _legalDocs = [];

  @override
  void initState() {
    super.initState();
    _nameFocus.addListener(() => setState(() {}));
    _phoneFocus.addListener(() => setState(() {}));
    _nameCtrl.addListener(() => setState(() {}));
    _phoneCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  // ─── إصلاح الرقم ──────────────────────────────────────────
  void _onPhoneChanged(String value) {
    String cleaned = value.replaceAll(RegExp(r'\D'), '');
    if (cleaned.startsWith('963')) cleaned = cleaned.substring(3);
    if (cleaned.startsWith('0')) cleaned = cleaned.substring(1);
    if (cleaned.length > 9) cleaned = cleaned.substring(0, 9);
    if (cleaned != value) {
      _phoneCtrl.value = TextEditingValue(
        text: cleaned,
        selection: TextSelection.collapsed(offset: cleaned.length),
      );
    }
    setState(() {});
  }

  bool get _valid =>
      _nameCtrl.text.trim().isNotEmpty &&
      _phoneCtrl.text.trim().length >= 7 &&
      _licenseCountry != null &&
      _agreed;

  InputDecoration _dec(
    String label,
    IconData icon,
    bool focused, {
    bool req = false,
    String? hint,
  }) => InputDecoration(
    prefixIcon: Icon(
      icon,
      color: focused ? Colors.green : Colors.grey.shade600,
    ),
    label: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        if (req) const Text(' *', style: TextStyle(color: Colors.red)),
      ],
    ),
    hintText: hint,
    filled: true,
    fillColor: Colors.grey.shade100,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Colors.green, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide.none,
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Colors.green, width: 2),
    ),
    errorStyle: const TextStyle(color: Colors.transparent, height: 0),
    contentPadding: const EdgeInsets.symmetric(vertical: 18),
  );

  Future<void> _register() async {
    if (!_valid || _sending) return;
    setState(() => _sending = true);

    final phone = buildAuthPhone(_code, _phoneCtrl.text.trim());
    final prov = context.read<AuthProvider>();

    final ok = await prov.sendOtp(phone);

    if (!mounted) return;
    setState(() => _sending = false);

    if (kDebugMode) debugPrint('OTP sent: $ok');
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(prov.error ?? 'Error'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpScreen(
          phone: phone,
          role: 'DRIVER',
          isLogin: false,
          registerData: {
            'name': _nameCtrl.text.trim(),
            'email': _emailCtrl.text.trim(),
            'licenseCountry': _licenseCountry!,
          },
        ),
      ),
    );
  }

  Future<void> _loadLegal(bool isAr) async {
    if (_legalDocs.isNotEmpty || _loadingLegal) return;
    setState(() => _loadingLegal = true);
    try {
      final docs = await LegalService.instance.fetchDriverBundle(isAr: isAr);
      if (mounted) setState(() => _legalDocs = docs);
    } catch (_) {
      /* fallback to arb */
    } finally {
      if (mounted) setState(() => _loadingLegal = false);
    }
  }

  void _showTerms(AppLocalizations local) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    _loadLegal(isAr);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.75,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    local.termsTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _loadingLegal
                    ? const Center(child: CircularProgressIndicator())
                    : _legalDocs.isEmpty
                        ? SingleChildScrollView(
                            child: Text(
                              local.termsContent,
                              style: const TextStyle(height: 1.6),
                            ),
                          )
                        : ListView(
                            children: _legalDocs
                                .map(
                                  (doc) => ListTile(
                                    title: Text(
                                      doc.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Text(doc.summary),
                                    trailing: const Icon(Icons.chevron_right),
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              LegalDocumentScreen(document: doc),
                                        ),
                                      );
                                    },
                                  ),
                                )
                                .toList(),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final prov = context.watch<AuthProvider>();
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/welcome_driver.jpg',
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.65)),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Align(
                      alignment: isAr ? Alignment.topRight : Alignment.topLeft,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      local.register,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.96),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              // Name
                              TextFormField(
                                controller: _nameCtrl,
                                focusNode: _nameFocus,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[a-zA-Z\u0600-\u06FF\s]'),
                                  ),
                                ],
                                decoration: _dec(
                                  local.fullName,
                                  Icons.person_outline,
                                  _nameFocus.hasFocus,
                                  req: true,
                                  hint: local.fullNameHint,
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Email (optional)
                              TextFormField(
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                decoration: _dec(
                                  '${local.email} (${local.optional})',
                                  Icons.mail_outline,
                                  false,
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Phone
                              TextFormField(
                                controller: _phoneCtrl,
                                focusNode: _phoneFocus,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                maxLength: 9,
                                decoration:
                                    _dec(
                                      local.phone,
                                      Icons.smartphone_rounded,
                                      _phoneFocus.hasFocus,
                                      req: true,
                                      hint: local.phoneHint,
                                    ).copyWith(
                                      counterText: '',
                                      prefixIcon: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const SizedBox(width: 4),
                                          CountryCodePicker(
                                            onChanged: (c) => setState(
                                              () =>
                                                  _code = c.dialCode ?? '+963',
                                            ),
                                            initialSelection: 'SY',
                                            favorite: const ['SY', 'AE', 'SA'],
                                            showDropDownButton: true,
                                            padding: EdgeInsets.zero,
                                            alignLeft: false,
                                          ),
                                          Transform.translate(
                                            offset: const Offset(-18, 0),
                                            child: Container(
                                              height: 24,
                                              width: 1,
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                        ],
                                      ),
                                    ),
                                onChanged: _onPhoneChanged,
                              ),
                              const SizedBox(height: 14),

                              // License Country
                              GestureDetector(
                                onTap: () => showCountryPicker(
                                  context: context,
                                  showPhoneCode: false,
                                  onSelect: (c) =>
                                      setState(() => _licenseCountry = c.name),
                                ),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: _licenseCountry != null
                                          ? Colors.green
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.flag_circle_rounded),
                                          const SizedBox(width: 8),
                                          Text(
                                            _licenseCountry ??
                                                local.licenseCountryHint,
                                          ),
                                          const Text(
                                            ' *',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ],
                                      ),
                                      const Icon(Icons.expand_more),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Terms
                              Row(
                                children: [
                                  Checkbox(
                                    value: _agreed,
                                    activeColor: Colors.green,
                                    onChanged: (v) =>
                                        setState(() => _agreed = v ?? false),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => _showTerms(local),
                                      child: Text(
                                        local.termsAgreement,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: _valid
                                        ? Colors.black
                                        : Colors.black.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(18),
                                    onTap: (_valid && !_sending) ? _register : null,
                                    child: Center(
                                      child: _sending
                                          ? const CircularProgressIndicator(
                                              color: Colors.white,
                                            )
                                          : Text(
                                              local.createAccount,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                local.legalText,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.black54,
                                  height: 1.6,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
