import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novaride_driver/features/driver/navigation/driver_entry.dart';
import 'package:novaride_driver/features/driver/navigation/driver_onboarding_router.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/services/legal_service.dart';
import '../../../core/widgets/otp_code_input.dart';
import '../providers/auth_provider.dart';
import '../../driver/onboarding/personal_info/personal_info_screen.dart';
import '../welcome/welcome_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  final String role;
  final bool isLogin;
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
  final _otpKey = GlobalKey<OtpCodeInputState>();
  Timer? _timer;
  int _sec = 60;
  bool _isError = false;
  bool _verifying = false;
  int _verifySeq = 0;
  String _otp = '';

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _sec = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_sec == 0) {
        t.cancel();
      } else {
        setState(() => _sec--);
      }
    });
  }

  bool get _complete => _otp.length == 6;

  void _clear() {
    _otpKey.currentState?.clear();
    setState(() {
      _otp = '';
      _isError = false;
    });
  }

  Future<void> _verify([String? codeOverride]) async {
    final otp = (codeOverride ?? _otp).trim();
    if (otp.length != 6 || _verifying) return;
    _verifying = true;
    final seq = ++_verifySeq;
    setState(() {
      _otp = otp;
    });
    _otpFocusUnfocus();

    final t = AppLocalizations.of(context)!;
    final prov = context.read<AuthProvider>();
    final ok = await prov.verifyOtp(
      widget.phone,
      otp,
      role: widget.role,
      consents: widget.isLogin ? null : LegalService.instance.driverConsents(),
    );

    if (!mounted || seq != _verifySeq) return;
    setState(() => _verifying = false);

    if (!ok) {
      setState(() => _isError = true);
      HapticFeedback.heavyImpact();
      _snack(
        _friendlyError(prov.error ?? t.invalidOtpCode),
        Colors.red.shade600,
      );
      Future.delayed(const Duration(milliseconds: 400), _clear);
      return;
    }

    TextInput.finishAutofillContext(shouldSave: false);

    if (widget.isLogin) {
      final driver = prov.driver;
      if (driver != null && driver.isRejected) {
        await prov.logout();
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          (_) => false,
        );
        _snack(t.actionFailed, Colors.red.shade600);
        return;
      }
      if (driver != null && driver.isApproved) {
        if (!mounted) return;
        unawaited(DriverEntry.goAfterAuth(context, driverId: driver.id));
        return;
      }
      if (driver != null) {
        unawaited(
          DriverOnboardingRouter.resumePending(context, driver: driver),
        );
        return;
      }
      if (!mounted) return;
      unawaited(_finishLoginRouting(prov));
      return;
    }

    if (!mounted) return;
    unawaited(DriverOnboardingRouter.saveStep(DriverOnboardingStep.personalInfo));
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const PersonalInfoScreen()),
      (_) => false,
    );

    if (widget.registerData != null) {
      final d = widget.registerData!;
      final parts = (d['name'] ?? '').split(' ');
      final body = <String, dynamic>{};
      if (parts.isNotEmpty && parts.first.isNotEmpty) {
        body['firstName'] = parts.first;
      }
      if (parts.length > 1) body['lastName'] = parts.sublist(1).join(' ');
      if ((d['email'] ?? '').isNotEmpty) body['email'] = d['email'];
      if ((d['licenseCountry'] ?? '').isNotEmpty) {
        body['licenseCountry'] = d['licenseCountry'];
      }
      if (body.isNotEmpty) unawaited(prov.updateInfo(body));
    }
  }

  void _otpFocusUnfocus() => FocusManager.instance.primaryFocus?.unfocus();

  String _friendlyError(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('timeout') ||
        raw.contains('مهلة') ||
        raw.contains('تأخر')) {
      return 'الخادم تأخر في الرد — حاول مجدداً';
    }
    if (lower.contains('socket') || raw.contains('الاتصال بالخادم')) {
      return 'تعذّر الاتصال بالخادم — تحقق من الإنترنت';
    }
    if (lower.contains('invalid') && lower.contains('otp')) {
      return 'رمز غير صحيح — استخدم آخر SMS واضغط إعادة إرسال إذا لزم';
    }
    if (lower.contains('sms') || raw.contains('SMS_DELIVERY')) {
      return 'تعذّر إرسال SMS — حاول بعد قليل';
    }
    return raw;
  }

  Future<void> _finishLoginRouting(AuthProvider prov) async {
    final status = await prov.checkDriverStatus();
    if (!mounted) return;
    if (status == DriverStatus.rejected) {
      await prov.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (_) => false,
      );
      return;
    }
    if (status == DriverStatus.approved) {
      unawaited(DriverEntry.goAfterAuth(context, driverId: prov.driver?.id));
    } else {
      unawaited(
        DriverOnboardingRouter.resumePending(
          context,
          driver: prov.driver,
        ),
      );
    }
  }

  void _goPending() => unawaited(
    DriverOnboardingRouter.resumePending(
      context,
      driver: context.read<AuthProvider>().driver,
    ),
  );

  Future<void> _resend() async {
    final t = AppLocalizations.of(context)!;
    final prov = context.read<AuthProvider>();
    final ok = widget.isLogin
        ? await prov.sendLoginOtp(widget.phone, role: widget.role)
        : await prov.sendOtp(widget.phone, role: widget.role);
    if (!mounted) return;
    if (ok) {
      _clear();
      _startTimer();
      await _otpKey.currentState?.restartListening();
      _snack('Code sent!', Colors.green);
    } else {
      _snack(_friendlyError(prov.error ?? t.actionFailed), Colors.red.shade600);
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
            const SizedBox(height: 8),
            Text(
              'قد يستغرق وصول الرسالة 10–30 ثانية. إذا لم تصل، اضغط إعادة إرسال.',
              style: TextStyle(color: Colors.grey[500], fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 40),
            OtpCodeInput(
              key: _otpKey,
              hasError: _isError,
              enabled: !_verifying,
              onChanged: (v) => setState(() {
                _otp = v;
                _isError = false;
              }),
              onCompleted: _verify,
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
                onPressed: (_complete && !_verifying) ? _verify : null,
                child: _verifying
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
                      onPressed: (_verifying || prov.sendingOtp)
                          ? null
                          : _resend,
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
