import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_endpoints.dart';
import 'auth_session.dart';

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
  });
}

class ApiClient {
  static final http.Client _client = http.Client();

  static Future<ApiResponse<dynamic>> get(String path, {Map<String, String>? queryParams}) async {
    try {
      final uri = Uri.parse('${ApiEndpoints.baseUrl}$path').replace(queryParameters: queryParams);
      final response = await _client
          .get(uri, headers: AuthSession.authHeaders)
          .timeout(const Duration(seconds: 5));

      final jsonMap = jsonDecode(response.body);
      return ApiResponse<dynamic>(
        success: jsonMap['success'] ?? (response.statusCode >= 200 && response.statusCode < 300),
        message: jsonMap['message'] ?? 'Berhasil mengambil data',
        data: jsonMap['data'],
      );
    } catch (e) {
      return ApiResponse<dynamic>(
        success: false,
        message: 'Koneksi backend: $e',
      );
    }
  }

  static Future<ApiResponse<dynamic>> post(String path, Map<String, dynamic> body) async {
    try {
      final uri = Uri.parse('${ApiEndpoints.baseUrl}$path');
      final response = await _client
          .post(uri, headers: AuthSession.authHeaders, body: jsonEncode(body))
          .timeout(const Duration(seconds: 5));

      final jsonMap = jsonDecode(response.body);
      return ApiResponse<dynamic>(
        success: jsonMap['success'] ?? (response.statusCode >= 200 && response.statusCode < 300),
        message: jsonMap['message'] ?? 'Berhasil memproses data',
        data: jsonMap['data'],
      );
    } catch (e) {
      return ApiResponse<dynamic>(
        success: false,
        message: 'Koneksi backend: $e',
      );
    }
  }

  static Future<ApiResponse<dynamic>> patch(String path, Map<String, dynamic> body) async {
    try {
      final uri = Uri.parse('${ApiEndpoints.baseUrl}$path');
      final response = await _client
          .patch(uri, headers: AuthSession.authHeaders, body: jsonEncode(body))
          .timeout(const Duration(seconds: 5));

      final jsonMap = jsonDecode(response.body);
      return ApiResponse<dynamic>(
        success: jsonMap['success'] ?? (response.statusCode >= 200 && response.statusCode < 300),
        message: jsonMap['message'] ?? 'Berhasil memperbarui data',
        data: jsonMap['data'],
      );
    } catch (e) {
      return ApiResponse<dynamic>(
        success: false,
        message: 'Koneksi backend: $e',
      );
    }
  }

  static Future<ApiResponse<dynamic>> put(String path, Map<String, dynamic> body) async {
    try {
      final uri = Uri.parse('${ApiEndpoints.baseUrl}$path');
      final response = await _client
          .put(uri, headers: AuthSession.authHeaders, body: jsonEncode(body))
          .timeout(const Duration(seconds: 5));

      final jsonMap = jsonDecode(response.body);
      return ApiResponse<dynamic>(
        success: jsonMap['success'] ?? (response.statusCode >= 200 && response.statusCode < 300),
        message: jsonMap['message'] ?? 'Berhasil memperbarui data',
        data: jsonMap['data'],
      );
    } catch (e) {
      return ApiResponse<dynamic>(
        success: false,
        message: 'Koneksi backend: $e',
      );
    }
  }

  static Future<ApiResponse<dynamic>> delete(String path) async {
    try {
      final uri = Uri.parse('${ApiEndpoints.baseUrl}$path');
      final response = await _client
          .delete(uri, headers: AuthSession.authHeaders)
          .timeout(const Duration(seconds: 5));

      final jsonMap = jsonDecode(response.body);
      return ApiResponse<dynamic>(
        success: jsonMap['success'] ?? (response.statusCode >= 200 && response.statusCode < 300),
        message: jsonMap['message'] ?? 'Berhasil menghapus data',
        data: jsonMap['data'],
      );
    } catch (e) {
      return ApiResponse<dynamic>(
        success: false,
        message: 'Koneksi backend: $e',
      );
    }
  }
}
