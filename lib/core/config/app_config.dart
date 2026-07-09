import 'dart:io';

/// Centralized, environment-driven configuration.
///
/// Values are injected at build/run time via `--dart-define` or
/// `--dart-define-from-file=config/<env>.json`. When nothing is provided
/// (e.g. a quick `flutter run` with no flags) it falls back to sensible
/// local-development defaults so the app still works out of the box.
///
/// Usage:
///   flutter run         --dart-define-from-file=config/dev.json
///   flutter build apk   --dart-define-from-file=config/prod.json
///   flutter build ipa   --dart-define-from-file=config/prod.json
class AppConfig {
  AppConfig._();

  static const String _envName =
      String.fromEnvironment('APP_ENV', defaultValue: 'dev');

  static const String _apiBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// dev | staging | prod
  static String get environment => _envName;
  static bool get isProd => _envName == 'prod';
  static bool get isStaging => _envName == 'staging';
  static bool get isDev => _envName == 'dev';

  /// The base URL of the backend API for the active environment.
  static String get apiBaseUrl {
    if (_apiBaseUrl.isNotEmpty) {
      if (isProd && !_apiBaseUrl.startsWith('https://')) {
        throw StateError('Production API_BASE_URL must use HTTPS');
      }
      return _apiBaseUrl;
    }

    if (isProd) {
      throw StateError('API_BASE_URL is required for production builds');
    }

    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://172.20.10.4:3000';
  }

  /// Crash reporting is enabled outside of local dev by default, but can be
  /// overridden explicitly via --dart-define=ENABLE_CRASHLYTICS=true|false.
  static bool get crashlyticsEnabled {
    const override = String.fromEnvironment('ENABLE_CRASHLYTICS');
    if (override == 'true') return true;
    if (override == 'false') return false;
    return !isDev;
  }
}
