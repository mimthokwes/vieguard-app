import '../models/admin_model.dart';

class AuthSession {
  static String? accessToken;
  static String? refreshToken;
  static AdminModel? currentAdmin;

  static bool get isLoggedIn => accessToken != null && currentAdmin != null;

  static void setSession({
    required String token,
    required String refresh,
    required AdminModel admin,
  }) {
    accessToken = token;
    refreshToken = refresh;
    currentAdmin = admin;
  }

  static void clearSession() {
    accessToken = null;
    refreshToken = null;
    currentAdmin = null;
  }

  static Map<String, String> get authHeaders {
    final headers = {'Content-Type': 'application/json'};
    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }
    return headers;
  }
}
