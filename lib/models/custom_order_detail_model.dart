import '../core/api/api_config.dart';
import '../core/utils/parsing.dart';

class CustomOrderDetail {
  final String? designReference;
  final String? designDescription;
  final String? jenisJenjang;
  final String? consultationNote;

  CustomOrderDetail({this.designReference, this.designDescription, this.jenisJenjang, this.consultationNote});

  factory CustomOrderDetail.fromJson(Map<String, dynamic> json) {
    final rawRef = json['designReference'] as String?;
    final resolvedRef = (rawRef != null && !rawRef.startsWith('http'))
        ? resolveMediaUrl(rawRef, ApiConfig.origin)
        : rawRef;
    return CustomOrderDetail(
      designReference: resolvedRef,
      designDescription: json['designDescription'] as String?,
      jenisJenjang: json['jenisJenjang'] as String?,
      consultationNote: json['consultationNote'] as String?,
    );
  }
}

