import 'package:flutter/foundation.dart';

import '../core/api/api_client.dart';
import '../core/api/api_exception.dart';
import '../core/storage/cache_storage.dart';
import '../core/storage/image_cache_service.dart';
import '../core/storage/token_storage.dart';
import '../models/admin_model.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final ApiClient apiClient;
  final TokenStorage tokenStorage;

  AuthProvider({required this.apiClient, required this.tokenStorage}) {
    apiClient.onSessionExpired = _handleSessionExpired;
  }

  AuthStatus status = AuthStatus.unknown;
  Admin? currentAdmin;
  bool isLoading = false;
  String? errorMessage;

  Future<void> tryAutoLogin() async {
    final token = await tokenStorage.readAccessToken();
    if (token == null) {
      status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    try {
      final data = await apiClient.get('/account/me');
      var admin = Admin.fromJson(data as Map<String, dynamic>);
      final savedPhoto = await tokenStorage.readAdminPhoto();
      if ((admin.profilePhoto == null || admin.profilePhoto!.isEmpty) && savedPhoto != null) {
        admin = admin.copyWith(profilePhoto: savedPhoto);
      }
      currentAdmin = admin;
      status = AuthStatus.authenticated;
    } on ApiException {
      await tokenStorage.clear();
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final data = await apiClient.post('/auth/login', data: {'email': email, 'password': password});
      currentAdmin = Admin.fromJson(data['admin'] as Map<String, dynamic>);
      await tokenStorage.save(accessToken: data['accessToken'] as String, refreshToken: data['refreshToken'] as String);
      status = AuthStatus.authenticated;
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final data = await apiClient.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
      });
      currentAdmin = Admin.fromJson(data['admin'] as Map<String, dynamic>);
      await tokenStorage.save(accessToken: data['accessToken'] as String, refreshToken: data['refreshToken'] as String);
      status = AuthStatus.authenticated;
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loginWithGoogle({
    String? credential,
    String? idToken,
    String? email,
    String? name,
    String? picture,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final payload = <String, dynamic>{};
      if (credential != null) payload['credential'] = credential;
      if (idToken != null) payload['idToken'] = idToken;
      if (email != null) payload['email'] = email;
      if (name != null) payload['name'] = name;
      if (picture != null) payload['picture'] = picture;
      final data = await apiClient.post('/auth/google', data: payload);
      var admin = Admin.fromJson(data['admin'] as Map<String, dynamic>);
      final photoToUse = (admin.profilePhoto != null && admin.profilePhoto!.isNotEmpty)
          ? admin.profilePhoto
          : picture;
      if (photoToUse != null && photoToUse.isNotEmpty) {
        admin = admin.copyWith(profilePhoto: photoToUse);
        await tokenStorage.saveAdminPhoto(photoToUse);
      }
      currentAdmin = admin;
      await tokenStorage.save(accessToken: data['accessToken'] as String, refreshToken: data['refreshToken'] as String);
      status = AuthStatus.authenticated;
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> requestPasswordReset(String email) async {
    errorMessage = null;
    try {
      await apiClient.post('/auth/forgot-password', data: {'email': email});
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      return false;
    }
  }

  Future<bool> resetPassword({required String email, required String otpCode, required String newPassword}) async {
    errorMessage = null;
    try {
      await apiClient.post('/auth/reset-password', data: {'email': email, 'otpCode': otpCode, 'newPassword': newPassword});
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      return false;
    }
  }

  Future<bool> updateProfile({String? name, String? phone}) async {
    try {
      final data = await apiClient.put('/account/me', data: {
        if (name != null && name.isNotEmpty) 'name': name,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      });
      currentAdmin = Admin.fromJson(data as Map<String, dynamic>);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword({required String oldPassword, required String newPassword}) async {
    try {
      await apiClient.patch('/account/change-password', data: {'oldPassword': oldPassword, 'newPassword': newPassword});
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final refreshToken = await tokenStorage.readRefreshToken();
    try {
      await apiClient.post('/auth/logout', data: {'refreshToken': refreshToken});
    } catch (_) {
      // ignore network errors on logout
    }
    await _handleSessionExpired();
  }

  Future<void> _handleSessionExpired() async {
    await tokenStorage.clear();
    await CacheStorage.clearAll();
    await ImageCacheService.clearCache();
    currentAdmin = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
