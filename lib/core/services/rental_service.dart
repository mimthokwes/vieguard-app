import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/rental_model.dart';

class RentalService {
  static Future<ApiResponse<List<RentalModel>>> fetchCalendar({
    String? startDate,
    String? endDate,
  }) async {
    final Map<String, String> queryParams = {};
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final response = await ApiClient.get(ApiEndpoints.rentalCalendar, queryParams: queryParams);

    if (response.success && response.data != null && response.data is List) {
      final list = (response.data as List).map((i) => RentalModel.fromJson(i)).toList();
      return ApiResponse<List<RentalModel>>(
        success: true,
        message: response.message,
        data: list,
      );
    }

    return ApiResponse<List<RentalModel>>(
      success: response.success,
      message: response.message,
      data: <RentalModel>[],
    );
  }

  static Future<ApiResponse<RentalModel>> updateStatus({
    required String id,
    required String status, // 'dipesan', 'diambil', 'dikembalikan', 'terlambat'
    String? itemConditionBefore,
    String? itemConditionAfter,
    double penaltyAmount = 0.0,
    String? damageNote,
  }) async {
    final response = await ApiClient.patch(
      ApiEndpoints.updateRentalStatus(id),
      {
        'status': status,
        if (itemConditionBefore != null) 'itemConditionBefore': itemConditionBefore,
        if (itemConditionAfter != null) 'itemConditionAfter': itemConditionAfter,
        'penaltyAmount': penaltyAmount,
        if (damageNote != null) 'damageNote': damageNote,
      },
    );

    if (response.success && response.data != null) {
      return ApiResponse<RentalModel>(
        success: true,
        message: response.message,
        data: RentalModel.fromJson(response.data),
      );
    }

    return ApiResponse<RentalModel>(
      success: response.success,
      message: response.message,
    );
  }
}
