import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/product_model.dart';

class ProductService {
  static Future<ApiResponse<List<ProductModel>>> fetchProducts() async {
    final response = await ApiClient.get(ApiEndpoints.products);

    if (response.success && response.data != null && response.data is List) {
      final list = (response.data as List).map((i) => ProductModel.fromJson(i)).toList();
      return ApiResponse<List<ProductModel>>(
        success: true,
        message: response.message,
        data: list,
      );
    }

    return ApiResponse<List<ProductModel>>(
      success: response.success,
      message: response.message,
      data: <ProductModel>[],
    );
  }

  static Future<ApiResponse<ProductModel>> fetchProductDetail(String id) async {
    final response = await ApiClient.get(ApiEndpoints.productDetail(id));

    if (response.success && response.data != null) {
      return ApiResponse<ProductModel>(
        success: true,
        message: response.message,
        data: ProductModel.fromJson(response.data),
      );
    }

    return ApiResponse<ProductModel>(
      success: false,
      message: response.message,
      data: null,
    );
  }

  static Future<ApiResponse<List<CategoryModel>>> fetchCategories() async {
    final response = await ApiClient.get(ApiEndpoints.categories);

    if (response.success && response.data != null && response.data is List) {
      final list = (response.data as List).map((i) => CategoryModel.fromJson(i)).toList();
      return ApiResponse<List<CategoryModel>>(
        success: true,
        message: response.message,
        data: list,
      );
    }

    return ApiResponse<List<CategoryModel>>(
      success: response.success,
      message: response.message,
      data: <CategoryModel>[],
    );
  }
}
