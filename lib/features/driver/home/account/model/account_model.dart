import '../../../../../core/utils/media_url.dart';

class AccountModel {
  final String id, phone;
  String name, email, profileImage;
  final bool isVerified;
  final int totalTrips, acceptedTrips, cancelledTrips;
  final double rating; // rating مباشرة

  AccountModel({
    required this.id,
    required this.phone,
    required this.name,
    required this.email,
    required this.profileImage,
    required this.isVerified,
    required this.totalTrips,
    required this.rating,
    required this.acceptedTrips,
    required this.cancelledTrips,
  });

  double get acceptanceRate =>
      totalTrips == 0 ? 0 : (acceptedTrips / totalTrips) * 100;
  double get cancelRate =>
      totalTrips == 0 ? 0 : (cancelledTrips / totalTrips) * 100;

  AccountModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? profileImage,
  }) => AccountModel(
    id: id,
    phone: phone ?? this.phone,
    name: name ?? this.name,
    email: email ?? this.email,
    profileImage: profileImage ?? this.profileImage,
    isVerified: isVerified,
    totalTrips: totalTrips,
    rating: rating,
    acceptedTrips: acceptedTrips,
    cancelledTrips: cancelledTrips,
  );

  factory AccountModel.fromJson(Map<String, dynamic> j) {
    final fn = j['firstName']?.toString() ?? '';
    final ln = j['lastName']?.toString() ?? '';
    final fullName = [fn, ln].where((s) => s.isNotEmpty).join(' ');

    return AccountModel(
      id: j['id']?.toString() ?? '',
      phone: j['phone']?.toString() ?? '',
      name: fullName.isNotEmpty ? fullName : (j['name']?.toString() ?? ''),
      email: j['email']?.toString() ?? '',
      profileImage: resolveMediaUrl(
            j['profileImage']?.toString() ?? j['driverPhoto']?.toString(),
          ) ??
          '',
      isVerified: j['isApproved'] == true,
      totalTrips: _parseInt(j['totalTrips']),
      rating: _parseDouble(j['rating']),
      acceptedTrips: _parseInt(j['acceptedTrips']),
      cancelledTrips: _parseInt(j['cancelledTrips']),
    );
  }

  static int _parseInt(dynamic v) => int.tryParse(v?.toString() ?? '0') ?? 0;
  static double _parseDouble(dynamic v) =>
      double.tryParse(v?.toString() ?? '0') ?? 0.0;
}
