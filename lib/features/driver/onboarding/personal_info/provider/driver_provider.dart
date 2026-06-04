import 'package:flutter/material.dart';
import '../model/driver_info_model.dart';
import '../service/driver_service.dart';

class DriverProvider extends ChangeNotifier {
  final DriverService _service = DriverService();

  bool isLoading = false;
  String? errorMessage;

  Future<bool> registerDriver(DriverInfoModel driver, String token) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _service.updatePersonalInfo(driver.toJson(), token);
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
