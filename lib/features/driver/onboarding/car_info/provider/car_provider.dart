import 'package:flutter/material.dart';
import '../service/car_service.dart';
import '../model/car_info_model.dart';

class CarProvider extends ChangeNotifier {
  final CarService _service = CarService();

  bool loading = false;
  String? errorMessage;
  CarModel car = CarModel();

  void setVehicleType(String? v) {
    car.vehicleType = v;
    notifyListeners();
  }

  void setPlateNumber(String? v) {
    car.plateNumber = v;
    notifyListeners();
  }

  void setBrand(String? v) {
    car.brand = v;
    notifyListeners();
  }

  void setModel(String? v) {
    car.model = v;
    notifyListeners();
  }

  void setYear(String? v) {
    car.year = v;
    notifyListeners();
  }

  void setColor(String? v) {
    car.color = v;
    notifyListeners();
  }

  void setPassengerCount(String? v) {
    car.passengerCount = v;
    notifyListeners();
  }

  void setEngineSize(String? v) {
    car.engineSize = v;
    notifyListeners();
  }

  // حقول جديدة لأنواع المركبات الإضافية
  void setTankerCapacity(int? v) {
    car.tankerCapacity = v;
    notifyListeners();
  }

  void setCargoVolume(int? v) {
    car.cargoVolume = v;
    notifyListeners();
  }

  void setHasPressureWasher(bool? v) {
    car.hasPressureWasher = v;
    notifyListeners();
  }

  void reset() {
    car = CarModel();
    notifyListeners();
  }

  Future<bool> submitCarInfo(String token) async {
    loading = true;
    errorMessage = null;
    notifyListeners();
    // داخل submitCarInfo
    //await _service.sendCarInfo(body , token);

    try {
      // جهّز الـ payload مع تضمين الحقول الجديدة فقط إن وُجدت
      final Map<String, dynamic> body = {
        'type': car.vehicleType,
        'plateNumber': car.plateNumber,
        'manufactureYear': car.year != null ? int.tryParse(car.year!) : null,
        'color': car.color,
        'brand': car.brand,
        'model': car.model,
        'passengerCount': car.passengerCount != null
            ? int.tryParse(car.passengerCount!)
            : null,
        'engineSize': car.engineSize != null
            ? int.tryParse(car.engineSize!)
            : null,
        'tankerCapacity': car.tankerCapacity,
        'cargoVolume': car.cargoVolume,
        'hasPressureWasher': car.hasPressureWasher,
      };

      // نظف الحقول null قبل الإرسال لأن الـ backend يتوقع حقول اختيارية
      body.removeWhere((key, value) => value == null);

      await _service.sendCarInfo(body, token);
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
