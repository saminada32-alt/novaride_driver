class LocationModel {
  final String city, area, address, startTime, endTime;
  //final double? latitude, longitude;

  const LocationModel({
    required this.city,
    required this.area,
    required this.address,
    required this.startTime,
    required this.endTime,
    //this.latitude,
    // this.longitude,
  });

  Map<String, dynamic> toJson() => {
    'city': city,
    'workArea': area,
    'address': address,
    'workStart': startTime,
    'workEnd': endTime,
    // if (latitude != null) 'latitude': latitude,
    // if (longitude != null) 'longitude': longitude,
  };
}
