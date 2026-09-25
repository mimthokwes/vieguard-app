class ProductVariantModel {
  final String id;
  final String size;
  final int stockBuy;
  final int stockRent;
  final double? priceBuyOverride;
  final double? priceRentOverride;

  ProductVariantModel({
    required this.id,
    required this.size,
    required this.stockBuy,
    required this.stockRent,
    this.priceBuyOverride,
    this.priceRentOverride,
  });

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    return ProductVariantModel(
      id: json['id']?.toString() ?? '',
      size: json['size'] ?? 'M',
      stockBuy: json['stockBuy'] ?? 0,
      stockRent: json['stockRent'] ?? 0,
      priceBuyOverride: double.tryParse(json['priceBuyOverride']?.toString() ?? ''),
      priceRentOverride: double.tryParse(json['priceRentOverride']?.toString() ?? ''),
    );
  }
}

class CategoryModel {
  final String id;
  final String name;
  final String? description;

  CategoryModel({
    required this.id,
    required this.name,
    this.description,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Kostum',
      description: json['description'],
    );
  }
}

class ProductModel {
  final String id;
  final String categoryId;
  final String name;
  final String? description;
  final double basePriceBuy;
  final double basePriceRent;
  final bool isCustomAvailable;
  final bool isVisible;
  final String? primaryImageUrl;
  final List<ProductVariantModel> variants;

  ProductModel({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description,
    required this.basePriceBuy,
    required this.basePriceRent,
    required this.isCustomAvailable,
    required this.isVisible,
    this.primaryImageUrl,
    required this.variants,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    var rawVariants = json['variants'] as List? ?? [];
    List<ProductVariantModel> parsedVariants = rawVariants.map((v) => ProductVariantModel.fromJson(v)).toList();

    String? imageUrl;
    if (json['images'] is List && (json['images'] as List).isNotEmpty) {
      imageUrl = json['images'][0]['imageUrl'];
    }

    return ProductModel(
      id: json['id']?.toString() ?? '',
      categoryId: json['categoryId']?.toString() ?? '',
      name: json['name'] ?? 'Kostum VieGuard',
      description: json['description'],
      basePriceBuy: double.tryParse(json['basePriceBuy']?.toString() ?? '0') ?? 0.0,
      basePriceRent: double.tryParse(json['basePriceRent']?.toString() ?? '0') ?? 0.0,
      isCustomAvailable: json['isCustomAvailable'] ?? false,
      isVisible: json['isVisible'] ?? true,
      primaryImageUrl: imageUrl,
      variants: parsedVariants,
    );
  }
}
