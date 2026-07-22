import 'package:shared_preferences/shared_preferences.dart';

/// Last known session flags — used when `/drivers/me` is slow or unreachable (Syria 2G/3G).
class SessionCache {
  SessionCache._();

  static const _driverStatus = 'driver_session_status';
  static const _driverOnboardingStep = 'driver_onboarding_step';

  static Future<void> saveDriverStatus(String status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_driverStatus, status);
  }

  static Future<String?> loadDriverStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_driverStatus);
  }

  static Future<void> saveDriverOnboardingStep(String step) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_driverOnboardingStep, step);
  }

  static Future<String?> loadDriverOnboardingStep() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_driverOnboardingStep);
  }

  static Future<void> clearDriver() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_driverStatus);
    await prefs.remove(_driverOnboardingStep);
  }
}
