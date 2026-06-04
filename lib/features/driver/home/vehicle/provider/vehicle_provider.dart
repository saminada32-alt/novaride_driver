import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../model/vehicle_model.dart';
import '../service/vehicle_service.dart';

class VehicleProvider extends ChangeNotifier {
  final VehicleService _service = VehicleService();
  final ImagePicker _picker = ImagePicker();

  VehicleModel? _vehicle;
  bool _isLoading = false;
  bool isSaving = false;
  String? _error;

  VehicleModel? get vehicle => _vehicle;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadVehicle(String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      _vehicle = await _service.fetchVehicle(token);
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateVehicle({
    required String token,
    required String brand,
    required String model,
    required String year,
    required String plate,
    required String color,
  }) async {
    isSaving = true;
    notifyListeners();
    try {
      await _service.updateVehicle(token, {
        'brand': brand,
        'model': model,
        'manufactureYear': int.tryParse(year),
        'plateNumber': plate,
        'color': color,
      });
      if (_vehicle != null) {
        _vehicle!
          ..brand = brand
          ..model = model
          ..year = year
          ..plateNumber = plate
          ..color = color;
      }
      isSaving = false;
      notifyListeners();
      return true;
    } catch (_) {
      isSaving = false;
      notifyListeners();
      return false;
    }
  }
}
