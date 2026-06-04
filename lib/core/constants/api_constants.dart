import '../config/app_config.dart';

class Api {
  Api._();

  /// عنوان الـ API حسب البيئة (dev/staging/prod) — يُحقن وقت البناء.
  static String get base => AppConfig.apiBaseUrl;

  // Auth
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';

  // Driver
  static const String driversMe = '/drivers/me';
  static const String driverStatus = '/drivers/me/status';
  static const String driverRating = '/drivers/me/rating';
  static const String submitApplication = '/drivers/me/submit';

  // Vehicle
  static const String vehiclesMe = '/vehicles/me';

  // Documents
  static const String uploadDoc = '/uploads/driver-document';

  // Location
  static const String workArea = '/locations/me/work-area';
  static const String workZones = '/locations/me/work-zones';
  static const String onShift = '/locations/me/on-shift';

  static const String balanceMe = '/balance/me';
  static const String balancePayout = '/balance/me/payout';
  static const String balancePayouts = '/balance/me/payouts';

  // Earnings
  static const String earningsDashboard = '/earnings/me/dashboard';

  // Rides
  static const String myRides = '/rides/me/driver';
  static const String pendingRides = '/rides/pending';
}
