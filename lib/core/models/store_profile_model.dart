class StoreProfileModel {
  final String id;
  final String storeName;
  final String description;
  final String address;
  final String phone;
  final String whatsappNumber;
  final String operationalHours;
  final double? latitude;
  final double? longitude;

  StoreProfileModel({
    required this.id,
    required this.storeName,
    required this.description,
    required this.address,
    required this.phone,
    required this.whatsappNumber,
    required this.operationalHours,
    this.latitude,
    this.longitude,
  });

  factory StoreProfileModel.fromJson(Map<String, dynamic> json) {
    return StoreProfileModel(
      id: json['id']?.toString() ?? '',
      storeName: json['storeName'] ?? 'VieGuard Medis Store Pusat',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      whatsappNumber: json['whatsappNumber'] ?? '',
      operationalHours: json['operationalHours'] ?? '08:00 - 17:00 WIB',
      latitude: double.tryParse(json['latitude']?.toString() ?? ''),
      longitude: double.tryParse(json['longitude']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
        'storeName': storeName,
        'description': description,
        'address': address,
        'phone': phone,
        'whatsappNumber': whatsappNumber,
        'operationalHours': operationalHours,
        'latitude': latitude,
        'longitude': longitude,
      };
}
