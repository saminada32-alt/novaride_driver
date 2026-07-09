import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';

class DriverVehicleType {
  final String id;
  final String labelAr;
  final String labelEn;
  final IconData icon;

  const DriverVehicleType({
    required this.id,
    required this.labelAr,
    required this.labelEn,
    required this.icon,
  });
}

class DriverVehicleCatalog {
  DriverVehicleCatalog._();

  static const hiddenTypeIds = {'scooter', 'wheelchair_accessible'};

  static const _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static final List<DriverVehicleType> fallback = [
    const DriverVehicleType(id: 'car', labelAr: 'سيارة', labelEn: 'Car', icon: Icons.directions_car),
    const DriverVehicleType(id: 'motorcycle', labelAr: 'موتور', labelEn: 'Motorcycle', icon: Icons.motorcycle),
    const DriverVehicleType(id: 'bike', labelAr: 'دراجة', labelEn: 'Bike', icon: Icons.pedal_bike_rounded),
    const DriverVehicleType(id: 'van', labelAr: 'فان', labelEn: 'Van', icon: Icons.airport_shuttle),
    const DriverVehicleType(id: 'water_tanker', labelAr: 'صهريج مياه', labelEn: 'Water tanker', icon: Icons.water),
    const DriverVehicleType(id: 'moving_truck', labelAr: 'نقل عفش', labelEn: 'Moving truck', icon: Icons.local_shipping),
    const DriverVehicleType(id: 'car_wash', labelAr: 'غسيل سيارات', labelEn: 'Car wash', icon: Icons.cleaning_services),
  ];

  static List<DriverVehicleType> _visible(List<DriverVehicleType> list) =>
      list.where((t) => !hiddenTypeIds.contains(t.id)).toList();

  static List<DriverVehicleType> _cached = _visible(fallback);
  static bool _loaded = false;

  static List<DriverVehicleType> get types => _cached;

  static Future<void> ensureLoaded() async {
    if (_loaded) return;
    try {
      final res = await http
          .get(
            Uri.parse('${Api.base}${Api.pricingDriverVehicleTypes}'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        if (data is List && data.isNotEmpty) {
          _cached = _visible(data.map((raw) {
            final e = raw as Map<String, dynamic>;
            final id = e['id'] as String;
            return DriverVehicleType(
              id: id,
              labelAr: e['labelAr'] as String? ?? id,
              labelEn: e['labelEn'] as String? ?? id,
              icon: _iconFor(e['icon'] as String? ?? id),
            );
          }).toList());
        }
      }
    } catch (_) {}
    _loaded = true;
  }

  static IconData _iconFor(String key) {
    switch (key) {
      case 'motorcycle':
        return Icons.motorcycle;
      case 'bike':
        return Icons.pedal_bike_rounded;
      case 'scooter':
        return Icons.electric_scooter_rounded;
      case 'van':
        return Icons.airport_shuttle;
      case 'water_tanker':
        return Icons.water;
      case 'moving_truck':
        return Icons.local_shipping;
      case 'car_wash':
        return Icons.cleaning_services;
      case 'wheelchair_accessible':
        return Icons.accessible_rounded;
      default:
        return Icons.directions_car;
    }
  }
}
