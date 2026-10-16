import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _accessKey = 'vg_access_token';
  static const _refreshKey = 'vg_refresh_token';
  static const _rememberKey = 'vg_remembered_email';

  final FlutterSecureStorage _secure = const FlutterSecureStorage();

  Future<void> save({
    required String accessToken,
    required String refreshToken
    }) async {
    await _secure.write(key: _accessKey,value:  accessToken);
    await _secure.write(key: _refreshKey,value: refreshToken);
  }

  Future<void> updateAccessToken(String accessToken) async {
    await _secure.write(key: _accessKey,value: accessToken);
  }

  Future<String?> readAccessToken() => _secure.read(key: _accessKey);

  Future<String?> readRefreshToken() => _secure.read(key: _refreshKey);

  Future<void> clear() async {
    await _secure.delete(key: _accessKey);
    await _secure.delete(key: _refreshKey);
  }

  Future<void> saveRememberedEmail(String? email) async {
    final prefs = await SharedPreferences.getInstance();
    if (email == null) {
      await prefs.remove(_rememberKey);
    } else {
      await prefs.setString(_rememberKey, email);
    }
  }

  Future<String?> readRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_rememberKey);
  }

  // migration: untuk pengguna yang sudah terlanjut menggunakan shared_preference maka sysem akan menggunakan migrate untuk mengganti penggunaan penyimpanan token
  Future<void> migrateLegacyTokens() async {
    final prefs = await SharedPreferences.getInstance();
    final oldAccess = prefs.getString(_accessKey);
    final oldRefresh = prefs.getString(_refreshKey);

    if (oldAccess != null) {
      await _secure.write(key: _accessKey, value: oldAccess);
      await prefs.remove(_accessKey);
    }
    if (oldRefresh != null) {
      await _secure.write(key: _refreshKey, value: oldRefresh);
      await prefs.remove(_refreshKey);
    }
  }

}
