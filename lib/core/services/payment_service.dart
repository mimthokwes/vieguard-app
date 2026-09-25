import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/payment_model.dart';

class PaymentService {
  static Future<ApiResponse<List<PaymentModel>>> fetchPayments({String? status}) async {
    final Map<String, String> queryParams = {};
    if (status != null && status.isNotEmpty) queryParams['status'] = status;

    final response = await ApiClient.get(ApiEndpoints.payments, queryParams: queryParams);

    if (response.success && response.data != null && response.data is List) {
      final list = (response.data as List).map((i) => PaymentModel.fromJson(i)).toList();
      return ApiResponse<List<PaymentModel>>(
        success: true,
        message: response.message,
        data: list,
      );
    }

    return ApiResponse<List<PaymentModel>>(
      success: response.success,
      message: response.message,
      data: <PaymentModel>[],
    );
  }

  static Future<ApiResponse<PaymentModel>> verifyPayment({
    required String id,
    required String status, // 'terverifikasi' or 'ditolak'
    String? refundReason,
  }) async {
    final response = await ApiClient.patch(
      ApiEndpoints.verifyPayment(id),
      {
        'status': status,
        if (refundReason != null) 'refundReason': refundReason,
      },
    );

    if (response.success && response.data != null) {
      return ApiResponse<PaymentModel>(
        success: true,
        message: response.message,
        data: PaymentModel.fromJson(response.data),
      );
    }

    return ApiResponse<PaymentModel>(
      success: response.success,
      message: response.message,
    );
  }
}
