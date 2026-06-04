class CarModel {
  String?
  vehicleType; // car | motorcycle | van | water_tanker | moving_truck | car_wash
  String? plateNumber;
  String? brand;
  String? model;
  String?
  year; // kept as String for UI binding; converted when building payload
  String? color;
  String? passengerCount; // used for van or engine size for motor as string
  String? engineSize;

  // حقول جديدة
  int? tankerCapacity; // liters
  int? cargoVolume; // cubic meters
  bool? hasPressureWasher;

  CarModel({
    this.vehicleType,
    this.plateNumber,
    this.brand,
    this.model,
    this.year,
    this.color,
    this.passengerCount,
    this.engineSize,
    this.tankerCapacity,
    this.cargoVolume,
    this.hasPressureWasher,
  });

  /// تحويل إلى خريطة جاهزة للإرسال إلى الـ API
  /// - يحول الحقول النصية إلى أعداد صحيحة حيث يلزم
  /// - يستخدم مفاتيح متوافقة مع DTO في الـ backend
  Map<String, dynamic> toPayload() {
    final Map<String, dynamic> m = {
      'type': vehicleType,
      'plateNumber': plateNumber,
      'manufactureYear': year != null ? int.tryParse(year!) : null,
      'color': color,
      'brand': brand,
      'model': model,
      'passengerCount': passengerCount != null
          ? int.tryParse(passengerCount!)
          : null,
      'engineSize': engineSize != null ? int.tryParse(engineSize!) : null,
      'tankerCapacity': tankerCapacity,
      'cargoVolume': cargoVolume,
      'hasPressureWasher': hasPressureWasher,
    };

    m.removeWhere((key, value) => value == null);
    return m;
  }

  /// قد تحتاج أيضاً إلى toJson قديمة أو متوافقة مع التخزين المحلي
  Map<String, dynamic> toJson() => {
    'vehicleType': vehicleType,
    'plateNumber': plateNumber,
    'brand': brand,
    'model': model,
    'year': year,
    'color': color,
    'passengerCount': passengerCount,
    'engineSize': engineSize,
    'tankerCapacity': tankerCapacity,
    'cargoVolume': cargoVolume,
    'hasPressureWasher': hasPressureWasher,
  };

  factory CarModel.fromJson(Map<String, dynamic> json) => CarModel(
    vehicleType: json['type'] ?? json['vehicleType'],
    plateNumber: json['plateNumber'] ?? json['plate_number'],
    brand: json['brand'],
    model: json['model'],
    year: json['manufactureYear'] != null
        ? (json['manufactureYear'].toString())
        : (json['year']?.toString()),
    color: json['color'],
    passengerCount: json['passengerCount'] != null
        ? json['passengerCount'].toString()
        : null,
    engineSize: json['engineSize'] != null
        ? json['engineSize'].toString()
        : null,
    tankerCapacity: json['tankerCapacity'],
    cargoVolume: json['cargoVolume'],
    hasPressureWasher: json['hasPressureWasher'],
  );

  CarModel copyWith({
    String? vehicleType,
    String? plateNumber,
    String? brand,
    String? model,
    String? year,
    String? color,
    String? passengerCount,
    String? engineSize,
    int? tankerCapacity,
    int? cargoVolume,
    bool? hasPressureWasher,
  }) {
    return CarModel(
      vehicleType: vehicleType ?? this.vehicleType,
      plateNumber: plateNumber ?? this.plateNumber,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      color: color ?? this.color,
      passengerCount: passengerCount ?? this.passengerCount,
      engineSize: engineSize ?? this.engineSize,
      tankerCapacity: tankerCapacity ?? this.tankerCapacity,
      cargoVolume: cargoVolume ?? this.cargoVolume,
      hasPressureWasher: hasPressureWasher ?? this.hasPressureWasher,
    );
  }
}
