import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Centralized crash + error reporting (Firebase Crashlytics).
///
/// Call [init] once after Firebase.initializeApp() when available.
/// Handlers swallow uncaught errors so the app stays open on flaky networks.
class CrashReporting {
  CrashReporting._();

  static FirebaseCrashlytics? _crashlytics;
  static bool get _enabled => _crashlytics != null;

  static Future<void> init() async {
    try {
      _crashlytics = FirebaseCrashlytics.instance;
      await _crashlytics!.setCrashlyticsCollectionEnabled(!kDebugMode);
    } catch (e) {
      _crashlytics = null;
      if (kDebugMode) debugPrint('Crashlytics unavailable: $e');
    }

    FlutterError.onError = (FlutterErrorDetails details) {
      if (kDebugMode) {
        FlutterError.presentError(details);
      }
      if (_enabled) {
        _crashlytics!.recordFlutterFatalError(details);
      }
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      if (_enabled) {
        _crashlytics!.recordError(error, stack, fatal: true);
      } else if (kDebugMode) {
        debugPrint('Uncaught error: $error\n$stack');
      }
      return true;
    };
  }

  static Future<void> setUser({required String id, String? role}) async {
    if (!_enabled) return;
    try {
      await _crashlytics!.setUserIdentifier(id);
      if (role != null) await _crashlytics!.setCustomKey('role', role);
    } catch (_) {}
  }

  static Future<void> clearUser() async {
    if (!_enabled) return;
    try {
      await _crashlytics!.setUserIdentifier('');
    } catch (_) {}
  }

  static Future<void> log(String message) async {
    if (!_enabled) return;
    try {
      await _crashlytics!.log(message);
    } catch (_) {}
  }

  static Future<void> recordError(
    Object error,
    StackTrace? stack, {
    bool fatal = false,
  }) async {
    if (!_enabled) {
      if (kDebugMode) debugPrint('Error: $error');
      return;
    }
    try {
      await _crashlytics!.recordError(error, stack, fatal: fatal);
    } catch (_) {}
  }

  static void testCrash() {
    _crashlytics?.crash();
  }
}
