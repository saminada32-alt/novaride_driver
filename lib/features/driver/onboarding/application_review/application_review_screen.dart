import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../pending/pending_approval_screen.dart';

class ApplicationReviewScreen extends StatefulWidget {
  const ApplicationReviewScreen({super.key});
  @override
  State<ApplicationReviewScreen> createState() =>
      _ApplicationReviewScreenState();
}

class _ApplicationReviewScreenState extends State<ApplicationReviewScreen> {
  bool _submitting = false;
  bool _submitted = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // ─── يُرسل الطلب فقط من هون ─────────────────────────────
    WidgetsBinding.instance.addPostFrameCallback((_) => _submit());
  }

  Future<void> _submit() async {
    if (_submitted) return;
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final prov = context.read<AuthProvider>();
      final ok = await prov.submitApplication();
      if (!mounted) return;
      if (ok) {
        setState(() {
          _submitting = false;
          _submitted = true;
        });
      } else {
        setState(() {
          _submitting = false;
          _error = 'Failed to submit application. Please try again.';
        });
      }
    } catch (e) {
      if (mounted)
        setState(() {
          _submitting = false;
          _error = e.toString();
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: const [
              Icon(Icons.directions_car, color: Colors.green),
              SizedBox(width: 8),
              Text(
                'NovaRide',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: _submitting
                ? _loading(isAr)
                : _error != null
                ? _errorWidget(isAr)
                : _success(isAr),
          ),
        ),
      ),
    );
  }

  Widget _loading(bool isAr) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const SizedBox(
        width: 60,
        height: 60,
        child: CircularProgressIndicator(color: Colors.green, strokeWidth: 3),
      ),
      const SizedBox(height: 24),
      Text(
        isAr
            ? 'جاري إرسال طلبك للمراجعة...'
            : 'Submitting your application for review...',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        textAlign: TextAlign.center,
      ),
    ],
  );

  Widget _errorWidget(bool isAr) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.error_outline, color: Colors.red, size: 54),
      ),
      const SizedBox(height: 24),
      Text(
        isAr ? 'حدث خطأ' : 'Something went wrong',
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 12),
      Text(
        _error ?? '',
        style: TextStyle(color: Colors.grey[600]),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 28),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _submit,
          icon: const Icon(Icons.refresh, color: Colors.white),
          label: Text(
            isAr ? 'إعادة المحاولة' : 'Try Again',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ),
    ],
  );

  Widget _success(bool isAr) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      // تم استبدال الأيقونة بصورة من الأصول
      SizedBox(
        width: 130,
        height: 130,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            'assets/images/waiting_driver.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // احتياطي في حال لم تُحمّل الصورة
              return Container(
                color: Colors.green.withOpacity(.1),
                child: const Icon(
                  Icons.person_outline,
                  color: Colors.green,
                  size: 70,
                ),
              );
            },
          ),
        ),
      ),
      const SizedBox(height: 32),
      Text(
        isAr ? '🎉 تم إرسال طلبك بنجاح!' : '🎉 Application Submitted!',
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 16),
      Text(
        isAr
            ? 'شكراً على انضمامك إلى NovaRide.\nسيقوم فريقنا بمراجعة طلبك وإشعارك فور الموافقة.'
            : 'Thank you for joining NovaRide.\nOur team will review your application and notify you shortly.',
        style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.7),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 36),

      // Steps
      _step(
        Icons.check_circle,
        Colors.green,
        isAr ? 'تم التسجيل' : 'Registered',
      ),
      _line(),
      _step(
        Icons.file_present,
        Colors.green,
        isAr ? 'تم رفع الوثائق' : 'Documents Uploaded',
      ),
      _line(),
      _step(
        Icons.send,
        Colors.green,
        isAr ? 'تم إرسال الطلب' : 'Application Sent',
      ),
      _line(),
      _step(
        Icons.hourglass_top,
        Colors.orange,
        isAr ? 'قيد المراجعة' : 'Under Review',
      ),
      _line(),
      _step(
        Icons.verified_user,
        Colors.grey,
        isAr ? 'انتظار الموافقة' : 'Awaiting Approval',
      ),

      const SizedBox(height: 32),

      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.withOpacity(.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.blue, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isAr
                    ? '⏱ وقت المراجعة عادةً 1-2 يوم عمل'
                    : '⏱ Review usually takes 1-2 business days',
                style: const TextStyle(fontSize: 13, color: Colors.blue),
              ),
            ),
          ],
        ),
      ),

      const SizedBox(height: 24),

      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const PendingApprovalScreen()),
            (_) => false,
          ),
          child: Text(
            isAr ? 'متابعة' : 'Continue',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    ],
  );

  Widget _step(IconData icon, Color c, String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Icon(icon, color: c, size: 22),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    ),
  );

  Widget _line() => Padding(
    padding: const EdgeInsets.only(left: 10),
    child: Container(width: 2, height: 16, color: Colors.grey.shade200),
  );
}
