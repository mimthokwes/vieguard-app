import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/store_profile_model.dart';
import '../models/admin_model.dart';

class StoreService {
  static Future<ApiResponse<StoreProfileModel>> fetchStoreProfile() async {
    final response = await ApiClient.get(ApiEndpoints.storeProfile);

    if (response.success && response.data != null) {
      return ApiResponse<StoreProfileModel>(
        success: true,
        message: response.message,
        data: StoreProfileModel.fromJson(response.data),
      );
    }

    return ApiResponse<StoreProfileModel>(
      success: response.success,
      message: response.message,
      data: null,
    );
  }

  static Future<ApiResponse<StoreProfileModel>> updateStoreProfile(StoreProfileModel profile) async {
    final response = await ApiClient.put(
      ApiEndpoints.storeProfile,
      profile.toJson(),
    );

    if (response.success && response.data != null) {
      return ApiResponse<StoreProfileModel>(
        success: true,
        message: response.message,
        data: StoreProfileModel.fromJson(response.data),
      );
    }

    return ApiResponse<StoreProfileModel>(
      success: response.success,
      message: response.message,
      data: profile,
    );
  }

  static Future<ApiResponse<List<AdminModel>>> fetchStaffList() async {
    final response = await ApiClient.get(ApiEndpoints.admins);

    if (response.success && response.data != null && response.data is List) {
      final list = (response.data as List).map((i) => AdminModel.fromJson(i)).toList();
      return ApiResponse<List<AdminModel>>(
        success: true,
        message: response.message,
        data: list,
      );
    }

    return ApiResponse<List<AdminModel>>(
      success: response.success,
      message: response.message,
      data: <AdminModel>[],
    );
  }
}
