class DriverInfoModel {
  final String joinType;
  final String firstName;
  final String lastName;
  final String idNumber;
  final DateTime birthDate;
  final String? officeName;
  final String? officeLocation;

  const DriverInfoModel({
    required this.joinType,
    required this.firstName,
    required this.lastName,
    required this.idNumber,
    required this.birthDate,
    this.officeName,
    this.officeLocation,
  });

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'nationalId': idNumber,
    'birthDate': birthDate.toIso8601String(),
    'isCompany': joinType == 'office',
    if (officeName != null) 'companyName': officeName,
    if (officeLocation != null) 'companyAddress': officeLocation,
  };
}
