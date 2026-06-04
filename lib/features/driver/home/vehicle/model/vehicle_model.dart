class VehicleModel {
  final int id;
  String brand;
  String model;
  String year;
  String plateNumber;
  String color;
  String type;
  bool isVerified;
  String? imageUrl;

  VehicleModel({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.plateNumber,
    required this.color,
    required this.type,
    required this.isVerified,
    this.imageUrl,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> j) => VehicleModel(
    id: j['id'] ?? 0,
    brand: j['brand'] ?? '',
    model: j['model'] ?? '',
    year: j['manufactureYear']?.toString() ?? '',
    plateNumber: j['plateNumber'] ?? '',
    color: j['color'] ?? '',
    type: j['type'] ?? 'car',
    isVerified: j['isVerified'] ?? false,
    imageUrl: j['imageUrl']?.toString(),
  );
}
