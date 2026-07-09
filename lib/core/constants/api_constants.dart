import '../config/app_config.dart';

class Api {
  Api._();

  /// عنوان الـ API حسب البيئة (dev/staging/prod) — يُحقن وقت البناء.
  static String get base => AppConfig.apiBaseUrl;

  // Auth
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';

  // Legal
  static String legalDocument(String slug) => '/legal/documents/$slug';

  // Driver
  static const String driversMe = '/drivers/me';
  static const String driverStatus = '/drivers/me/status';
  static const String driverRating = '/drivers/me/rating';
  static const String submitApplication = '/drivers/me/submit';
  static const String driverPreferences = '/drivers/me/preferences';
  static const String driverDestinationFilter = '/drivers/me/destination-filter';
  static const String driverAutoAccept = '/drivers/me/auto-accept';

  // Vehicle
  static const String vehiclesMe = '/vehicles/me';

  // Pricing / vehicle catalog
  static const String pricingDriverVehicleTypes = '/pricing/driver-vehicle-types';

  // Documents
  static const String uploadDoc = '/uploads/driver-document';
  static const String documentsMe = '/documents/me';

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
  static const String myScheduledRides = '/rides/me/driver/scheduled';
  static const String pendingRides = '/rides/pending';

  // Incentives
  static const String incentivesActive = '/incentives/active';

  // Referrals
  static const String referralsMe = '/referrals/me';

  // Content CMS
  static const String contentFaq = '/content/faq';

  // Ride actions
  static String rideAccept(int id) => '/rides/$id/accept';
  static String rideRejectOffer(int id) => '/rides/$id/reject-offer';
  static String rideStatus(int id) => '/rides/$id/status';
  static String rideCancel(int id) => '/rides/$id/cancel';
  static String ridePayment(int id) => '/rides/$id/payment';
  static String rideStopArrive(int rideId, int stopIndex) =>
      '/rides/$rideId/stops/$stopIndex/arrive';
  static String rideStopComplete(int rideId, int stopIndex) =>
      '/rides/$rideId/stops/$stopIndex/complete';
  static String ridePool(int id) => '/rides/$id/pool';
  static String rideRate(int id) => '/rides/$id/rate';
}
