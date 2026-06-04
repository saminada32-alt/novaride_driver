import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Centralized crash + error reporting (Firebase Crashlytics).
///
/// Call [init] once after Firebase.initializeApp(). Collection is disabled in
/// debug builds to avoid polluting the dashboard while developing.
class CrashReporting {
  CrashReporting._();

  static FirebaseCrashlytics get _c => FirebaseCrashlytics.instance;

  static Future<void> init() async {
    await _c.setCrashlyticsCollectionEnabled(!kDebugMode);

    // Flutter framework errors (build/layout/paint).
    final previousOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      previousOnError?.call(details);
      _c.recordFlutterFatalError(details);
    };

    // Uncaught async errors outside the Flutter framework.
    PlatformDispatcher.instance.onError = (error, stack) {
      _c.recordError(error, stack, fatal: true);
      return true;
    };
  }

  /// Attach the signed-in user so crashes are traceable (no PII beyond id).
  static Future<void> setUser({required String id, String? role}) async {
    await _c.setUserIdentifier(id);
    if (role != null) await _c.setCustomKey('role', role);
  }

  static Future<void> clearUser() => _c.setUserIdentifier('');

  static Future<void> log(String message) => _c.log(message);

  static Future<void> recordError(
    Object error,
    StackTrace? stack, {
    bool fatal = false,
  }) =>
      _c.recordError(error, stack, fatal: fatal);

  /// For verifying the integration end-to-end (call once, then remove).
  static void testCrash() => _c.crash();
}
