import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/welcome/welcome_screen.dart';
import '../../features/driver/pending/pending_approval_screen.dart';
import '../driver/navigation/driver_entry.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
    _check();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    final results = await Future.wait([
      context.read<AuthProvider>().checkDriverStatus(),
      Future.delayed(const Duration(milliseconds: 500)),
    ]);
    if (!mounted) return;

    final status = results[0] as DriverStatus;

    switch (status) {
      // مسجّل ومعتمد أو معلّق → افتح التطبيق (HomeScreen يتعامل مع الحالتين)
      case DriverStatus.approved:
        if (!mounted) return;
        unawaited(DriverEntry.goAfterAuth(context));
        break;
      case DriverStatus.pending:
        _go(const PendingApprovalScreen());
        break;

      // مرفوض → خروج وWelcome
      case DriverStatus.rejected:
        await context.read<AuthProvider>().logout();
        if (mounted) _go(const WelcomeScreen());
        break;

      // مو مسجّل
      case DriverStatus.notLoggedIn:
        _go(const WelcomeScreen());
        break;
    }
  }

  void _go(Widget w) => Navigator.pushReplacement(
    context,
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (_, _, _) => w,
      transitionsBuilder: (_, a, _, c) => FadeTransition(opacity: a, child: c),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: FadeTransition(
      opacity: _fade,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.directions_car_rounded,
                color: Colors.white,
                size: 54,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'NovaRide',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Driver',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 60),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.green,
                strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
