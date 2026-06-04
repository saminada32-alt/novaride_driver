import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novaride_driver/features/driver/home/home_screen.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../../driver/onboarding/personal_info/personal_info_screen.dart';
import '../../driver/pending/pending_approval_screen.dart';
import '../../../core/services/socket_service.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  final String role;
  final bool isLogin; // ← جديد: هل هو login أم register
  final Map<String, String>? registerData;

  const OtpScreen({
    super.key,
    required this.phone,
    this.role = 'DRIVER',
    this.isLogin = true,
    this.registerData,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _ctrls = List.generate(6, (_) => TextEditingController());
  final _focus = List.generate(6, (_) => FocusNode());
  Timer? _timer;
  int _sec = 60;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _focus.first.requestFocus(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _ctrls) c.dispose();
    for (final f in _focus) f.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _sec = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_sec == 0)
        t.cancel();
      else
        setState(() => _sec--);
    });
  }

  String get _otp => _ctrls.map((c) => c.text).join();
  bool get _complete => _otp.length == 6;

  void _clear() {
    for (final c in _ctrls) c.clear();
    _focus.first.requestFocus();
    setState(() => _isError = false);
  }

  void _paste(String v) {
    if (v.length == 6 && RegExp(r'^\d{6}$').hasMatch(v)) {
      for (var i = 0; i < 6; i++) _ctrls[i].text = v[i];
      _focus.last.unfocus();
      setState(() {});
    }
  }

  Future<void> _verify() async {
    if (!_complete) return;
    final prov = context.read<AuthProvider>();
    final ok = await prov.verifyOtp(widget.phone, _otp, role: widget.role);

    if (!mounted) return;

    if (!ok) {
      HapticFeedback.heavyImpact();
      setState(() => _isError = true);
      Future.delayed(const Duration(milliseconds: 400), _clear);
      _snack(prov.error ?? 'Invalid code', Colors.red.shade600);
      return;
    }

    // Socket
    await DriverSocketService.instance.connect();
    // ══════════════════════════════════════════════════════════
    // FLOW:
    // LOGIN  → فحص الحالة → approved=Home | pending=PendingScreen
    // REGISTER → Onboarding (PersonalInfo → Car → Docs → Location)
    // ══════════════════════════════════════════════════════════

    if (widget.isLogin) {
      // ─── Login: فحص الحالة مباشرة ─────────────────────────
      final status = await prov.checkDriverStatus();
      if (!mounted) return;

      if (status == DriverStatus.approved) {
        _goHome();
      } else {
        _goPending();
      }
    } else {
      // ─── Register: حدّث المعلومات الأساسية ─────────────────
      if (widget.registerData != null) {
        final d = widget.registerData!;
        final parts = (d['name'] ?? '').split(' ');
        final body = <String, dynamic>{};
        if (parts.isNotEmpty && parts.first.isNotEmpty)
          body['firstName'] = parts.first;
        if (parts.length > 1) body['lastName'] = parts.sublist(1).join(' ');
        if ((d['email'] ?? '').isNotEmpty) body['email'] = d['email'];
        if ((d['licenseCountry'] ?? '').isNotEmpty)
          body['licenseCountry'] = d['licenseCountry'];
        if (body.isNotEmpty) await prov.updateInfo(body);
      }

      if (!mounted) return;

      // ─── روح للـ Onboarding ────────────────────────────────
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const PersonalInfoScreen()),
        (_) => false,
      );
    }
  }

  void _goHome() => Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const DriverHomeScreen()),
    (_) => false,
  );

  void _goPending() => Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const PendingApprovalScreen()),
    (_) => false,
  );

  Future<void> _resend() async {
    final prov = context.read<AuthProvider>();
    final ok = await prov.sendOtp(widget.phone, role: widget.role);
    if (!mounted) return;
    if (ok) {
      _clear();
      _startTimer();
      _snack('Code sent!', Colors.green);
    } else {
      _snack(prov.error ?? 'Failed', Colors.red.shade600);
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
    final prov = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Center(
              child: Icon(Icons.lock_outline, size: 80, color: Colors.black),
            ),
            const SizedBox(height: 28),
            Text(
              local.otpTitle,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              local.otpSubtitle(widget.phone),
              style: TextStyle(color: Colors.grey[600], height: 1.5),
            ),
            const SizedBox(height: 40),

            // OTP Boxes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                6,
                (i) => SizedBox(
                  width: 50,
                  height: 58,
                  child: TextField(
                    controller: _ctrls[i],
                    focusNode: _focus[i],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: _isError
                          ? Colors.red.shade100
                          : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.green,
                          width: 2,
                        ),
                      ),
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (v) {
                      if (v.length > 1) {
                        _paste(v);
                        return;
                      }
                      if (v.isNotEmpty && i < 5) _focus[i + 1].requestFocus();
                      if (v.isEmpty && i > 0) _focus[i - 1].requestFocus();
                      setState(() {});
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: (_complete && !prov.loading) ? _verify : null,
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
                        local.verify,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),
            Center(
              child: _sec > 0
                  ? Text(
                      local.resendIn(_sec),
                      style: TextStyle(color: Colors.grey[500]),
                    )
                  : TextButton(
                      onPressed: prov.loading ? null : _resend,
                      child: Text(
                        local.resendCode,
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
