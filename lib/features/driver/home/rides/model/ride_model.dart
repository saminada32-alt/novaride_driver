enum DriverRideStatus {
  searching,
  driver_assigned,
  driver_arrived,
  passenger_onboard,
  trip_started,
  completed,
  cancelled,
}

class DriverRideModel {
  final int id;
  final DriverRideStatus status;
  final double? estimatedFare;
  final double? estimatedDistanceKm;
  final int? etaMinutes;
  final double pickupLat;
  final double pickupLng;
  final double dropoffLat;
  final double dropoffLng;
  final String? pickupAddress; // ← أضيفي
  final String? dropoffAddress; // ← أضيفي
  final Map<String, dynamic>? passenger;
  final Map<String, dynamic>? vehicle;
  final String? vehicleType;
  final String? paymentMethod;
  final DateTime? createdAt;
  final String? promoCode;
  final double? originalFare;
  final double? discountAmount;
  final int? driverRating;
  final int? passengerRating;
  final String? paymentReference;

  bool get hasPromoDiscount =>
      promoCode != null && discountAmount != null && discountAmount! > 0;

  String? get passengerPhone => passenger?['phone']?.toString();

  const DriverRideModel({
    required this.id,
    required this.status,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffLat,
    required this.dropoffLng,
    this.pickupAddress,
    this.dropoffAddress,
    this.estimatedFare,
    this.estimatedDistanceKm,
    this.etaMinutes,
    this.passenger,
    this.vehicle,
    this.vehicleType,
    this.paymentMethod,
    this.createdAt,
    this.promoCode,
    this.originalFare,
    this.discountAmount,
    this.driverRating,
    this.passengerRating,
    this.paymentReference,
  });

  bool get isActive =>
      status == DriverRideStatus.driver_assigned ||
      status == DriverRideStatus.driver_arrived ||
      status == DriverRideStatus.passenger_onboard ||
      status == DriverRideStatus.trip_started;

  // الـ status التالي بالترتيب
  DriverRideStatus? get nextStatus {
    switch (status) {
      case DriverRideStatus.driver_assigned:
        return DriverRideStatus.driver_arrived;
      case DriverRideStatus.driver_arrived:
        return DriverRideStatus.passenger_onboard;
      case DriverRideStatus.passenger_onboard:
        return DriverRideStatus.trip_started;
      case DriverRideStatus.trip_started:
        return DriverRideStatus.completed;
      default:
        return null;
    }
  }

  String get nextStatusLabel {
    switch (status) {
      case DriverRideStatus.driver_assigned:
        return 'I Arrived';
      case DriverRideStatus.driver_arrived:
        return 'Passenger On Board';
      case DriverRideStatus.passenger_onboard:
        return 'Start Trip';
      case DriverRideStatus.trip_started:
        return 'Complete Trip';
      default:
        return '';
    }
  }

  static DriverRideStatus _parse(String? s) {
    switch (s?.toUpperCase()) {
      case 'DRIVER_ASSIGNED':
        return DriverRideStatus.driver_assigned;
      case 'DRIVER_ARRIVED':
        return DriverRideStatus.driver_arrived;
      case 'PASSENGER_ONBOARD':
        return DriverRideStatus.passenger_onboard;
      case 'TRIP_STARTED':
        return DriverRideStatus.trip_started;
      case 'COMPLETED':
        return DriverRideStatus.completed;
      case 'CANCELLED':
        return DriverRideStatus.cancelled;
      default:
        return DriverRideStatus.searching;
    }
  }

  factory DriverRideModel.fromJson(Map<String, dynamic> j) => DriverRideModel(
    id: j['id'],
    status: _parse(j['status']?.toString()),
    pickupLat: double.tryParse(j['pickupLat']?.toString() ?? '0') ?? 0,
    pickupLng: double.tryParse(j['pickupLng']?.toString() ?? '0') ?? 0,
    dropoffLat: double.tryParse(j['dropoffLat']?.toString() ?? '0') ?? 0,
    dropoffLng: double.tryParse(j['dropoffLng']?.toString() ?? '0') ?? 0,
    pickupAddress: j['pickupAddress']?.toString(),
    dropoffAddress: j['dropoffAddress']?.toString(),
    estimatedFare: double.tryParse(j['estimatedFare']?.toString() ?? ''),
    estimatedDistanceKm: double.tryParse(
      j['estimatedDistanceKm']?.toString() ?? '',
    ),
    etaMinutes: j['etaMinutes'],
    passenger: j['passenger'] != null
        ? Map<String, dynamic>.from(j['passenger'])
        : null,
    vehicle: j['vehicle'] != null
        ? Map<String, dynamic>.from(j['vehicle'])
        : null,
    vehicleType: j['vehicleType']?.toString(),
    paymentMethod: j['paymentMethod']?.toString(),
    createdAt: j['createdAt'] != null
        ? DateTime.tryParse(j['createdAt'])
        : null,
    promoCode: j['promoCode']?.toString(),
    originalFare: double.tryParse(j['originalFare']?.toString() ?? ''),
    discountAmount: double.tryParse(j['discountAmount']?.toString() ?? ''),
    driverRating: int.tryParse(j['driverRating']?.toString() ?? ''),
    passengerRating: int.tryParse(j['passengerRating']?.toString() ?? ''),
    paymentReference: j['paymentReference']?.toString(),
  );
}
