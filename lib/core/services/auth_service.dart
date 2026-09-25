import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../api/auth_session.dart';
import '../models/admin_model.dart';

class AuthService {
  static Future<ApiResponse<AdminModel>> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.post(
      ApiEndpoints.login,
      {
        'email': email,
        'password': password,
      },
    );

    if (response.success && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      final admin = AdminModel.fromJson(data['admin']);
      final accessToken = data['accessToken'] as String? ?? '';
      final refreshToken = data['refreshToken'] as String? ?? '';

      AuthSession.setSession(
        token: accessToken,
        refresh: refreshToken,
        admin: admin,
      );

      return ApiResponse<AdminModel>(
        success: true,
        message: response.message,
        data: admin,
      );
    }

    return ApiResponse<AdminModel>(
      success: false,
      message: response.message,
      data: null,
    );
  }

  static Future<ApiResponse<AdminModel>> fetchProfile() async {
    final response = await ApiClient.get(ApiEndpoints.profile);
    if (response.success && response.data != null) {
      final admin = AdminModel.fromJson(response.data as Map<String, dynamic>);
      AuthSession.currentAdmin = admin;
      return ApiResponse<AdminModel>(
        success: true,
        message: response.message,
        data: admin,
      );
    }
    return ApiResponse<AdminModel>(
      success: response.success,
      message: response.message,
      data: AuthSession.currentAdmin,
    );
  }
}
