import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/services/app_controller.dart';
import '../providers/auth_provider.dart';
import '../otp/otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _phoneCtrl = TextEditingController();
  String _code = '+963';

  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  // ─── إصلاح الرقم: احذف الصفر الأول ───────────────────────
  void _onPhoneChanged(String value) {
    String cleaned = value.replaceAll(RegExp(r'\D'), '');

    // احذف الصفر إذا كان الرقم الأول
    if (cleaned.startsWith('0')) {
      cleaned = cleaned.substring(1);
    }

    // max 9 أرقام
    if (cleaned.length > 9) cleaned = cleaned.substring(0, 9);

    if (cleaned != value) {
      _phoneCtrl.value = TextEditingValue(
        text: cleaned,
        selection: TextSelection.collapsed(offset: cleaned.length),
      );
    }
    setState(() {});
  }

  bool get _valid => _phoneCtrl.text.trim().length >= 7;

  Future<void> _send() async {
    final phone = '$_code${_phoneCtrl.text.trim()}';
    final provider = context.read<AuthProvider>();
    final ok = await provider.sendOtp(phone);
    if (!mounted) return;
    if (ok) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              OtpScreen(phone: phone, role: 'DRIVER', isLogin: true),
        ),
      );
    } else {
      _snack(provider.error ?? 'Error', Colors.red.shade600);
    }
  }

  void _snack(String m, Color c) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(m),
      backgroundColor: c,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final ctrl = context.watch<AppController>();
    final prov = context.watch<AuthProvider>();
    final isAr = ctrl.isArabic;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fade,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                          color: Colors.black87,
                          onPressed: () => Navigator.pop(context),
                        ),
                        TextButton(
                          onPressed: () =>
                              ctrl.changeLanguage(isAr ? 'en' : 'ar'),
                          child: Text(
                            isAr ? 'EN' : 'AR',
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    Text(
                      local.loginTitle,
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      local.loginSubtitle,
                      style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                    ),

                    const SizedBox(height: 50),

                    // Phone Input Card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.65),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  CountryCodePicker(
                                    onChanged: (c) => setState(
                                      () => _code = c.dialCode ?? '+963',
                                    ),
                                    initialSelection: 'SY',
                                    favorite: const ['+963', '+971', '+966'],
                                  ),
                                  Container(
                                    width: 1,
                                    height: 30,
                                    color: Colors.grey.shade300,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextField(
                                      controller: _phoneCtrl,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      maxLength: 9,
                                      decoration: InputDecoration(
                                        hintText: local.phoneHint,
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                        ),
                                        border: InputBorder.none,
                                        counterText: '',
                                      ),
                                      onChanged: _onPhoneChanged,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    disabledBackgroundColor:
                                        Colors.green.shade200,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: (_valid && !prov.loading)
                                      ? _send
                                      : null,
                                  child: prov.loading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          local.loginButton,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    Center(
                      child: Text(
                        'NovaRide Driver ©️ 2026',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
