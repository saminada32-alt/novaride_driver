import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/a11y.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/services/app_controller.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final ctrl = context.watch<AppController>();
    final isAr = ctrl.isArabic;

    return A11yScreen(
      label: l.language,
      child: Scaffold(
        backgroundColor: const Color(0xfff7f7f7),
        appBar: AppBar(
          title: Semantics(header: true, child: Text(l.language)),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0.5,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 300,
                height: 300,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/language.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.green.shade50,
                      child: const Icon(
                        Icons.language,
                        size: 120,
                        color: Color(0xff16a34a),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              _langButton(
                title: 'English',
                active: !isAr,
                onTap: () => context.read<AppController>().changeLanguage('en'),
              ),
              const SizedBox(height: 20),
              _langButton(
                title: 'العربية',
                active: isAr,
                onTap: () => context.read<AppController>().changeLanguage('ar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _langButton({
    required String title,
    required VoidCallback onTap,
    required bool active,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 180,
        height: 180,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: active
                ? [
                    const Color(0xff16a34a),
                    const Color(0xff16a34a).withValues(alpha: 0.7),
                  ]
                : [Colors.grey.shade300, Colors.grey.shade200],
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: active ? Colors.white : Colors.black54,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
