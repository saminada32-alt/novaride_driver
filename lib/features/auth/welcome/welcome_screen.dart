import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/services/app_controller.dart';
import '../login/login_screen.dart';
import '../register/register_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideCtrl, _steerCtrl;
  late Animation<Offset> _slide;
  late Animation<double> _rotate;
  double _parallax = 0;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutExpo));
    _slideCtrl.forward();
    _steerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _rotate = Tween<double>(
      begin: -0.15,
      end: 0.15,
    ).animate(CurvedAnimation(parent: _steerCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    _steerCtrl.dispose();
    super.dispose();
  }

  void _nav(Widget p) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => p,
        transitionsBuilder: (_, a, __, c) =>
            FadeTransition(opacity: a, child: c),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final ctrl = context.watch<AppController>();
    final isAr = ctrl.isArabic;

    return Scaffold(
      body: GestureDetector(
        onVerticalDragUpdate: (d) =>
            setState(() => _parallax += d.delta.dy * 0.2),
        child: Stack(
          children: [
            Positioned.fill(
              top: -250,
              child: Transform.translate(
                offset: Offset(0, _parallax),
                child: Image.asset(
                  'assets/images/welcome_driver.jpg',
                  fit: BoxFit.contain,
                ),
              ),
            ),

            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xAA000000),
                      Color(0x55000000),
                      Color(0x00000000),
                      Color(0xCC000000),
                    ],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: isAr ? Alignment.topLeft : Alignment.topRight,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.language, color: Colors.white),
                      onPressed: () => ctrl.changeLanguage(isAr ? 'en' : 'ar'),
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              top: 100,
              left: 20,
              right: 20,
              child: Text(
                local.welcomeTitle,
                textAlign: isAr ? TextAlign.right : TextAlign.left,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: SlideTransition(
                position: _slide,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white30,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),

                          const SizedBox(height: 16),

                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'N',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                AnimatedBuilder(
                                  animation: _rotate,
                                  builder: (_, __) => Transform.rotate(
                                    angle: _rotate.value,
                                    child: const Icon(
                                      Icons.directions_car_rounded,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                ),
                                const Text(
                                  'vaRide',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),
                          Text(
                            local.welcomeSubtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () => _nav(const LoginScreen()),
                              child: Text(
                                local.signIn,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () => _nav(const RegisterScreen()),
                              child: Text(
                                local.register,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),
                          Text(
                            'NovaRide Driver ©️ 2026',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
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
