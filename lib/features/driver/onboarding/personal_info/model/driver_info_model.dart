class DriverInfoModel {
  final String firstName;
  final String lastName;
  final String idNumber;
  final DateTime birthDate;

  const DriverInfoModel({
    required this.firstName,
    required this.lastName,
    required this.idNumber,
    required this.birthDate,
  });

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'nationalId': idNumber,
    'birthDate': birthDate.toIso8601String(),
    'isCompany': false,
  };
}
