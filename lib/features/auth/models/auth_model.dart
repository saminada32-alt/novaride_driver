class DriverModel {
  final int id;
  final String phone;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? licenseCountry;
  final bool isApproved;
  final bool isRejected;
  final String status;
  final double rating;

  const DriverModel({
    required this.id,
    required this.phone,
    this.firstName,
    this.lastName,
    this.email,
    this.licenseCountry,
    required this.isApproved,
    required this.isRejected,
    required this.status,
    required this.rating,
  });

  bool get isPending => !isApproved && !isRejected;
  String get fullName => (firstName != null && lastName != null)
      ? '$firstName $lastName'
      : firstName ?? lastName ?? phone;

  factory DriverModel.fromJson(Map<String, dynamic> j) => DriverModel(
    id: j['id'],
    phone: j['phone'] ?? '',
    firstName: j['firstName'],
    lastName: j['lastName'],
    email: j['email'],
    licenseCountry: j['licenseCountry'],
    isApproved: j['isApproved'] ?? false,
    isRejected: j['isRejected'] ?? false,
    status: j['status'] ?? 'offline',
    // ─── إصلاح rating String/double ──────────────────────
    rating: double.tryParse(j['rating']?.toString() ?? '0') ?? 0.0,
  );
}

class AuthResult {
  final String accessToken;
  final DriverModel driver;
  final bool isNew;

  const AuthResult({
    required this.accessToken,
    required this.driver,
    required this.isNew,
  });

  factory AuthResult.fromJson(Map<String, dynamic> j) => AuthResult(
    accessToken: j['access_token'],
    driver: DriverModel.fromJson(j['user']),
    isNew: j['isNew'] ?? false,
  );
}
