import '../core/api/api_config.dart';
import '../core/utils/parsing.dart';

class SizeEntry {
  final String? id;
  final String studentName;
  final String? gender;
  final int? heightCm;
  final String size;
  final String? role;

  SizeEntry({this.id, required this.studentName, this.gender, this.heightCm, required this.size, this.role});

  factory SizeEntry.fromJson(Map<String, dynamic> json) => SizeEntry(
        id: json['id']?.toString(),
        studentName: json['studentName'] as String? ?? '-',
        gender: json['gender'] as String?,
        heightCm: json['heightCm'] as int?,
        size: json['size'] as String? ?? '-',
        role: json['role'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'studentName': studentName,
        if (gender != null) 'gender': gender,
        if (heightCm != null) 'heightCm': heightCm,
        'size': size,
        if (role != null) 'role': role,
      };

  String get genderLabel => switch (gender?.toUpperCase()) { 'L' => 'Pria', 'P' => 'Wanita', _ => '-' };
}

class OrderPhoto {
  final String id;
  final String category;
  final String? title;
  final String imageUrl;
  final bool isPublic;
  final DateTime createdAt;

  OrderPhoto({required this.id, required this.category, this.title, required this.imageUrl, required this.isPublic, required this.createdAt});

  factory OrderPhoto.fromJson(Map<String, dynamic> json) => OrderPhoto(
        id: json['id'].toString(),
        category: json['category'] as String? ?? 'workshop',
        title: json['title'] as String?,
        imageUrl: resolveMediaUrl(json['imageUrl'] as String?, ApiConfig.origin) ?? '',
        isPublic: json['isPublic'] as bool? ?? true,
        createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      );
}

class CustomerSummary {
  final String id;
  final String name;
  final String? email;
  final String? phone;

  CustomerSummary({required this.id, required this.name, this.email, this.phone});

  factory CustomerSummary.fromJson(Map<String, dynamic> json) => CustomerSummary(
        id: json['id'].toString(),
        name: json['name'] as String? ?? '-',
        email: json['email'] as String?,
        phone: json['phone'] as String?,
      );
}
