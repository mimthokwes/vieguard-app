import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/order_model.dart';

class OrderService {
  static Future<ApiResponse<List<OrderModel>>> fetchOrders({
    String? status,
    String? orderType,
  }) async {
    final Map<String, String> queryParams = {};
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (orderType != null && orderType.isNotEmpty) queryParams['orderType'] = orderType;

    final response = await ApiClient.get(ApiEndpoints.orders, queryParams: queryParams);

    if (response.success && response.data != null && response.data is List) {
      final list = (response.data as List).map((item) => OrderModel.fromJson(item)).toList();
      return ApiResponse<List<OrderModel>>(
        success: true,
        message: response.message,
        data: list,
      );
    }

    return ApiResponse<List<OrderModel>>(
      success: response.success,
      message: response.message,
      data: <OrderModel>[],
    );
  }

  static Future<ApiResponse<OrderModel>> fetchOrderDetail(String id) async {
    final response = await ApiClient.get(ApiEndpoints.orderDetail(id));

    if (response.success && response.data != null) {
      return ApiResponse<OrderModel>(
        success: true,
        message: response.message,
        data: OrderModel.fromJson(response.data),
      );
    }

    return ApiResponse<OrderModel>(
      success: false,
      message: response.message,
      data: null,
    );
  }

  static Future<ApiResponse<OrderModel>> confirmOrder({
    required String id,
    required double dpAmount,
  }) async {
    final response = await ApiClient.patch(
      ApiEndpoints.confirmOrder(id),
      {'dpAmount': dpAmount},
    );

    if (response.success && response.data != null) {
      return ApiResponse<OrderModel>(
        success: true,
        message: response.message,
        data: OrderModel.fromJson(response.data),
      );
    }

    return ApiResponse<OrderModel>(
      success: response.success,
      message: response.message,
    );
  }

  static Future<ApiResponse<dynamic>> updateProgress({
    required String id,
    required int progressPercentage,
    required String statusLabel,
    String? note,
  }) async {
    final response = await ApiClient.patch(
      ApiEndpoints.updateOrderProgress(id),
      {
        'progressPercentage': progressPercentage,
        'statusLabel': statusLabel,
        if (note != null) 'note': note,
      },
    );

    return response;
  }
}
