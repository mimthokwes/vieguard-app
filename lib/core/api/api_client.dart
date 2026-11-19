import 'dart:convert';
import 'package:dio/dio.dart';

import '../storage/token_storage.dart';
import 'api_config.dart';
import 'api_exception.dart';

class ApiClient {
  final TokenStorage tokenStorage;
  final Dio _dio;
  void Function()? onSessionExpired;

  ApiClient({required this.tokenStorage})
      : _dio = Dio(BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await tokenStorage.readAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final isUnauthorized = error.response?.statusCode == 401;
        final isRefreshCall = error.requestOptions.path.contains('/auth/refresh');
        if (isUnauthorized && !isRefreshCall) {
          final refreshed = await _tryRefreshToken();
          if (refreshed != null) {
            final retryOptions = error.requestOptions;
            retryOptions.headers['Authorization'] = 'Bearer $refreshed';
            try {
              final response = await _dio.fetch(retryOptions);
              return handler.resolve(response);
            } catch (_) {
              // fall through to session expiry below
            }
          }
          await tokenStorage.clear();
          onSessionExpired?.call();
        }
        handler.next(error);
      },
    ));
  }

  Future<String?> _tryRefreshToken() async {
    final refreshToken = await tokenStorage.readRefreshToken();
    if (refreshToken == null) return null;
    try {
      final response = await _dio.post('/auth/refresh', data: {'refreshToken': refreshToken});
      final newAccess = response.data['data']['accessToken'] as String;
      await tokenStorage.updateAccessToken(newAccess);
      return newAccess;
    } catch (_) {
      return null;
    }
  }

  /// Memperbarui access token secara eksplisit melalui refresh token
  Future<String?> refreshToken() => _tryRefreshToken();

  /// Mengembalikan token yang valid, jika sudah kedaluwarsa akan otomatis diperbarui
  Future<String?> getValidAccessToken() async {
    var token = await tokenStorage.readAccessToken();
    if (token == null || isTokenExpired(token)) {
      final refreshed = await _tryRefreshToken();
      if (refreshed != null) {
        token = refreshed;
      }
    }
    return token;
  }

  /// Mengecek apakah access token sudah kedaluwarsa berdasarkan exp di payload JWT
  static bool isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payloadMap = jsonDecode(decoded);
      if (payloadMap is Map && payloadMap.containsKey('exp')) {
        final exp = payloadMap['exp'];
        if (exp is int) {
          final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
          return DateTime.now().isAfter(expiryDate.subtract(const Duration(minutes: 1)));
        }
      }
      return false;
    } catch (_) {
      return true;
    }
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) => _unwrap(_dio.get(path, queryParameters: query));

  Future<dynamic> post(String path, {Map<String, dynamic>? data}) => _unwrap(_dio.post(path, data: data));

  Future<dynamic> patch(String path, {Map<String, dynamic>? data}) => _unwrap(_dio.patch(path, data: data));

  Future<dynamic> put(String path, {Map<String, dynamic>? data}) => _unwrap(_dio.put(path, data: data));

  Future<dynamic> delete(String path) => _unwrap(_dio.delete(path));

  Future<dynamic> postForm(String path, FormData form) => _unwrap(_dio.post(path, data: form));

  Future<dynamic> patchForm(String path, FormData form) => _unwrap(_dio.patch(path, data: form));

  static MultipartFile imageFile(List<int> bytes, String filename) {
    final ext = filename.split('.').last.toLowerCase();
    final type = ext == 'png' ? 'png' : (ext == 'webp' ? 'webp' : 'jpeg');
    return MultipartFile.fromBytes(bytes, filename: filename, contentType: DioMediaType('image', type));
  }

  Future<List<int>> downloadBytes(String path) async {
    try {
      final response = await _dio.get<List<int>>(path, options: Options(responseType: ResponseType.bytes));
      return response.data ?? [];
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Gagal mengunduh berkas', statusCode: e.response?.statusCode);
    }
  }

  Future<dynamic> _unwrap(Future<Response> request) async {
    try {
      final response = await request;
      return response.data['data'];
    } on DioException catch (e) {
      final message = e.response?.data is Map ? (e.response?.data['message'] as String?) : null;
      throw ApiException(message ?? e.message ?? 'Terjadi kesalahan jaringan', statusCode: e.response?.statusCode);
    }
  }
}
