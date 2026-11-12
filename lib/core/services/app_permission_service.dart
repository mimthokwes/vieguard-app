import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPermissionService {
  AppPermissionService._();

  static const String _keyPrompted = 'vieguard_permissions_prompted_v1';

  /// Cek apakah dialog izin awal sudah pernah ditampilkan sebelumnya
  static Future<bool> hasPromptedInitial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyPrompted) ?? false;
  }

  /// Tandai bahwa dialog izin awal sudah pernah ditampilkan
  static Future<void> markPrompted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPrompted, true);
  }

  /// Minta semua izin utama (Push Notifikasi, Kamera, File/Foto)
  static Future<Map<Permission, PermissionStatus>> requestAllPermissions() async {
    try {
      final statuses = await [
        Permission.notification,
        Permission.camera,
        Permission.photos,
        Permission.storage,
      ].request();

      await markPrompted();
      return statuses;
    } catch (e) {
      debugPrint('AppPermissionService.requestAllPermissions error: $e');
      await markPrompted();
      return {};
    }
  }

  /// Minta izin notifikasi secara spesifik
  static Future<bool> requestNotification() async {
    final status = await Permission.notification.request();
    return status == PermissionStatus.granted || status == PermissionStatus.limited;
  }

  /// Minta izin kamera
  static Future<bool> requestCamera() async {
    final status = await Permission.camera.request();
    return status == PermissionStatus.granted;
  }

  /// Minta izin akses file / foto
  static Future<bool> requestStorage() async {
    final photoStatus = await Permission.photos.request();
    if (photoStatus == PermissionStatus.granted || photoStatus == PermissionStatus.limited) return true;
    final storageStatus = await Permission.storage.request();
    return storageStatus == PermissionStatus.granted || storageStatus == PermissionStatus.limited;
  }
}
