import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Default map coords per city id (matches SyriaCitiesCatalog / API).
abstract final class SyriaCityCoords {
  static const Map<String, LatLng> _coords = {
    'damascus': LatLng(33.5138, 36.2765),
    'rif_damascus': LatLng(33.45, 36.45),
    'aleppo': LatLng(36.2021, 37.1343),
    'homs': LatLng(34.7324, 36.7138),
    'hama': LatLng(35.1318, 36.7578),
    'latakia': LatLng(35.5167, 35.7833),
    'tartus': LatLng(34.889, 35.8867),
    'daraa': LatLng(32.6189, 36.1021),
    'sweida': LatLng(32.7044, 36.5686),
    'deir_ez_zor': LatLng(35.3359, 40.1408),
    'hasakah': LatLng(36.5073, 40.7477),
  };

  static const LatLng fallback = LatLng(33.5138, 36.2765);

  static LatLng forCity(String cityId) =>
      _coords[cityId.trim().toLowerCase()] ?? fallback;
}
