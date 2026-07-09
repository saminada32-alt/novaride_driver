import '../config/app_config.dart';

/// Centralized Google Maps / Places / Geocoding API key.
class GoogleMapsConfig {
  GoogleMapsConfig._();

  static const String _override = String.fromEnvironment('GOOGLE_MAPS_API_KEY');

  static String get apiKey {
    if (_override.isNotEmpty) return _override;
    if (AppConfig.isProd) {
      throw StateError(
        'GOOGLE_MAPS_API_KEY is required for production builds',
      );
    }
    return '';
  }
}
