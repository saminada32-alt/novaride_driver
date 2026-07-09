import 'package:flutter/material.dart';
import '../model/location_model.dart';
import '../service/location_service.dart';
import '../syria_cities_catalog.dart';

class LocationProvider extends ChangeNotifier {
  final LocationService _service = LocationService();

  String? selectedCity;
  String? selectedArea;
  String? address;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  //double? latitude;
  //double? longitude;
  bool isLoading = false;
  String? errorMessage;

  LocationProvider() {
    final firstCity = SyriaCitiesCatalog.cities.first;
    selectedCity = firstCity.id;
    final areas = SyriaCitiesCatalog.areasFor(firstCity.id);
    if (areas.isNotEmpty) selectedArea = areas.first.id;
  }

  void updateCity(String city) {
    selectedCity = city;
    selectedArea = null;
    notifyListeners();
  }

  void updateArea(String area) {
    selectedArea = area;
    notifyListeners();
  }

  void updateAddress(String val) {
    address = val;
    notifyListeners();
  }

  void updateStartTime(TimeOfDay t) {
    startTime = t;
    notifyListeners();
  }

  void updateEndTime(TimeOfDay t) {
    endTime = t;
    notifyListeners();
  }

  bool get isValid =>
      selectedCity != null &&
      selectedArea != null &&
      (address?.isNotEmpty ?? false) &&
      startTime != null &&
      endTime != null;

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<bool> submit(String token) async {
    if (!isValid) return false;
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final model = LocationModel(
        city: selectedCity!,
        area: selectedArea!,
        address: address!,
        startTime: _fmt(startTime!),
        endTime: _fmt(endTime!),
        //latitude: latitude,
        //longitude: longitude,
      );
      return await _service.submitLocation(model, token);
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
