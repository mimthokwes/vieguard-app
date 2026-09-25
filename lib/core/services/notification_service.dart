import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/notification_model.dart';

class NotificationService {
  static Future<ApiResponse<List<NotificationModel>>> fetchNotifications() async {
    final response = await ApiClient.get(ApiEndpoints.notifications);

    if (response.success && response.data != null && response.data is List) {
      final list = (response.data as List).map((i) => NotificationModel.fromJson(i)).toList();
      return ApiResponse<List<NotificationModel>>(
        success: true,
        message: response.message,
        data: list,
      );
    }

    return ApiResponse<List<NotificationModel>>(
      success: response.success,
      message: response.message,
      data: <NotificationModel>[],
    );
  }
}
