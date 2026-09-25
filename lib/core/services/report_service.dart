import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/report_model.dart';

class ReportService {
  static Future<ApiResponse<ReportSummaryModel>> fetchSummary({
    String? startDate,
    String? endDate,
  }) async {
    final Map<String, String> queryParams = {};
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final response = await ApiClient.get(ApiEndpoints.reportSummary, queryParams: queryParams);

    if (response.success && response.data != null) {
      return ApiResponse<ReportSummaryModel>(
        success: true,
        message: response.message,
        data: ReportSummaryModel.fromJson(response.data),
      );
    }

    return ApiResponse<ReportSummaryModel>(
      success: response.success,
      message: response.message,
      data: null,
    );
  }
}
