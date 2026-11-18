import '../core/api/api_config.dart';
import '../core/utils/parsing.dart';

class SizeEntry {
  final String? id;
  final String studentName;
  final String? gender;
  final int? heightCm;
  final String size;
  final String? role;
  final int? chestCm;
  final int? waistCm;
  final int? shoulderCm;
  final int? armCm;
  final int? pantsCm;
  final int? headCm;

  SizeEntry({
    this.id,
    required this.studentName,
    this.gender,
    this.heightCm,
    required this.size,
    this.role,
    this.chestCm,
    this.waistCm,
    this.shoulderCm,
    this.armCm,
    this.pantsCm,
    this.headCm,
  });

  factory SizeEntry.fromJson(Map<String, dynamic> json) {
    int? parseNum(dynamic val) {
      if (val == null) return null;
      if (val is int) return val;
      if (val is num) return val.toInt();
      return int.tryParse(val.toString().replaceAll(RegExp(r'[^0-9]'), ''));
    }

    final rawRole = json['role'] as String?;

    // Ekstraksi tag regex jika ada di dalam role: [LD:86 LP:74 B:42 PL:58 PC:98 LK:56] atau variannya
    int? tagNum(String keyPattern) {
      if (rawRole == null) return null;
      final m = RegExp('$keyPattern:?\\s*([0-9]+)', caseSensitive: false).firstMatch(rawRole);
      return m != null ? int.tryParse(m.group(1)!) : null;
    }

    final chest = parseNum(json['chestCm'] ?? json['lingkarDada'] ?? json['dada']) ?? tagNum(r'(?:LD|Dada|D)');
    final waist = parseNum(json['waistCm'] ?? json['lingkarPinggang'] ?? json['pinggang']) ?? tagNum(r'(?:LP|Pinggang|P)');
    final shoulder = parseNum(json['shoulderCm'] ?? json['lebarBahu'] ?? json['bahu']) ?? tagNum(r'(?:Bahu|B|LB)');
    final arm = parseNum(json['armCm'] ?? json['panjangLengan'] ?? json['lengan']) ?? tagNum(r'(?:PL|Lengan|L)');
    final pants = parseNum(json['pantsCm'] ?? json['panjangCelana'] ?? json['celana']) ?? tagNum(r'(?:PC|Celana|Rok|C)');
    final head = parseNum(json['headCm'] ?? json['lingkarKepala'] ?? json['kepala'] ?? json['shako']) ?? tagNum(r'(?:LK|Kepala|Shako|K)');

    return SizeEntry(
      id: json['id']?.toString(),
      studentName: json['studentName'] as String? ?? json['name'] as String? ?? '-',
      gender: json['gender'] as String?,
      heightCm: parseNum(json['heightCm'] ?? json['height']),
      size: json['size'] as String? ?? '-',
      role: rawRole,
      chestCm: chest,
      waistCm: waist,
      shoulderCm: shoulder,
      armCm: arm,
      pantsCm: pants,
      headCm: head,
    );
  }

  Map<String, dynamic> toJson() => {
        'studentName': studentName,
        if (gender != null) 'gender': gender,
        if (heightCm != null) 'heightCm': heightCm,
        'size': size,
        if (role != null) 'role': role,
        if (chestCm != null) 'chestCm': chestCm,
        if (waistCm != null) 'waistCm': waistCm,
        if (shoulderCm != null) 'shoulderCm': shoulderCm,
        if (armCm != null) 'armCm': armCm,
        if (pantsCm != null) 'pantsCm': pantsCm,
        if (headCm != null) 'headCm': headCm,
      };

  SizeEntry copyWith({
    String? id,
    String? studentName,
    String? gender,
    int? heightCm,
    String? size,
    String? role,
    int? chestCm,
    int? waistCm,
    int? shoulderCm,
    int? armCm,
    int? pantsCm,
    int? headCm,
  }) =>
      SizeEntry(
        id: id ?? this.id,
        studentName: studentName ?? this.studentName,
        gender: gender ?? this.gender,
        heightCm: heightCm ?? this.heightCm,
        size: size ?? this.size,
        role: role ?? this.role,
        chestCm: chestCm ?? this.chestCm,
        waistCm: waistCm ?? this.waistCm,
        shoulderCm: shoulderCm ?? this.shoulderCm,
        armCm: armCm ?? this.armCm,
        pantsCm: pantsCm ?? this.pantsCm,
        headCm: headCm ?? this.headCm,
      );

  String get cleanRole {
    if (role == null) return '-';
    final cleaned = role!.replaceAll(RegExp(r'\[.*?\]'), '').trim();
    return cleaned.isEmpty ? (hasMeasurements ? 'Kustom' : '-') : cleaned;
  }

  bool get hasMeasurements =>
      chestCm != null ||
      waistCm != null ||
      shoulderCm != null ||
      armCm != null ||
      pantsCm != null ||
      headCm != null;

  String get measurementsSummary {
    final list = <String>[];
    if (chestCm != null) list.add('LD: ${chestCm}cm');
    if (waistCm != null) list.add('LP: ${waistCm}cm');
    if (shoulderCm != null) list.add('Bahu: ${shoulderCm}cm');
    if (armCm != null) list.add('Lengan: ${armCm}cm');
    if (pantsCm != null) list.add('Celana: ${pantsCm}cm');
    if (headCm != null) list.add('Kepala: ${headCm}cm');
    return list.join(' · ');
  }

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
