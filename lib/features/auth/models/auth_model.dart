class DriverModel {
  final int id;
  final String phone;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? licenseCountry;
  final bool isApproved;
  final bool isRejected;
  final bool applicationSubmitted;
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
    required this.applicationSubmitted,
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
    applicationSubmitted: j['applicationSubmitted'] ?? false,
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

  factory AuthResult.fromJson(Map<String, dynamic> j) {
    final token = j['access_token'] ?? j['accessToken'] ?? j['token'];
    final driverJson =
        j['user'] ?? j['driver'] ?? j['data']?['user'] ?? j['data']?['driver'];

    if (token == null || driverJson == null) {
      throw FormatException(
        'Invalid auth response: missing token or user data',
      );
    }

    return AuthResult(
      accessToken: token.toString(),
      driver: DriverModel.fromJson(
        Map<String, dynamic>.from(driverJson as Map),
      ),
      isNew: j['isNew'] ?? j['is_new'] ?? false,
    );
  }
}
