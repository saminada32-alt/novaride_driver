import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';

// Services
import 'core/services/driver_fcm_service.dart';
import 'core/services/app_controller.dart';
import 'core/services/crash_reporting.dart';
import 'core/services/network_connectivity_service.dart';

// Auth
import 'features/auth/providers/auth_provider.dart';

// Driver Providers
import 'features/driver/onboarding/personal_info/provider/driver_provider.dart';
import 'features/driver/onboarding/car_info/provider/car_provider.dart';
import 'features/driver/onboarding/documents/provider/document_provider.dart';
import 'features/driver/onboarding/location/provider/location_provider.dart';
import 'features/driver/home/account/provider/account_provider.dart';
import 'features/driver/home/earnings/provider/earning_provider.dart';
import 'features/driver/home/rides/provider/rides_provider.dart';
import 'features/driver/home/vehicle/provider/vehicle_provider.dart';

import 'app.dart';

@pragma('vm:entry-point')
Future<void> _fcmBackground(RemoteMessage msg) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    FirebaseMessaging.onBackgroundMessage(_fcmBackground);
  } catch (e, st) {
    debugPrint('FCM background handler setup failed: $e');
  }

  final appController = AppController();

  try {
    await Firebase.initializeApp();
  } catch (e, st) {
    debugPrint('Firebase init failed: $e');
  }

  await CrashReporting.init();
  await appController.loadLocale();

  final networkService = NetworkConnectivityService();
  unawaited(networkService.start());

  runApp(MyAppRoot(appCtrl: appController, networkService: networkService));
}

class MyAppRoot extends StatefulWidget {
  final AppController appCtrl;
  final NetworkConnectivityService networkService;
  const MyAppRoot({
    super.key,
    required this.appCtrl,
    required this.networkService,
  });

  @override
  State<MyAppRoot> createState() => _MyAppRootState();
}

class _MyAppRootState extends State<MyAppRoot> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_initServices());
    });
  }

  Future<void> _initServices() async {
    if (!mounted) return;
    try {
      await DriverFcmService.instance.init();
    } catch (e, st) {
      debugPrint('Driver FCM init failed: $e');
      unawaited(CrashReporting.recordError(e, st));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.appCtrl),
        ChangeNotifierProvider.value(value: widget.networkService),
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        ChangeNotifierProvider(create: (_) => DriverProvider()),
        ChangeNotifierProvider(create: (_) => CarProvider()),
        ChangeNotifierProvider(create: (_) => DocumentsProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),

        ChangeNotifierProvider(create: (_) => AccountProvider()),
        ChangeNotifierProvider(create: (_) => EarningProvider()),
        ChangeNotifierProvider(create: (_) => RidesProvider()),
        ChangeNotifierProvider(create: (_) => VehicleProvider()),
      ],
      child: const MyApp(),
    );
  }
}
