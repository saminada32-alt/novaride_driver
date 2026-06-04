import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/app_controller.dart';
import 'l10n/app_localizations.dart';
import 'features/auth/login/login_screen.dart';
import 'features/splash/splash_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<AppController>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: ctrl.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => Directionality(
        textDirection: ctrl.locale.languageCode == 'ar'
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: child!,
      ),
      routes: {'/login': (_) => const LoginScreen()},
      home: const SplashScreen(),
    );
  }
}
