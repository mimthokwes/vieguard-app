import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Penyimpanan cache lokal untuk data JSON API agar data tidak hilang saat restart
/// dan aplikasi dapat dibuka secara instan (offline-first).
class CacheStorage {
  CacheStorage._();

  static Directory? _dir;

  static Future<Directory> get _cacheDir async {
    if (_dir == null) {
      final base = await getApplicationDocumentsDirectory();
      final folder = Directory('${base.path}/vg_data_cache');
      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }
      _dir = folder;
    }
    return _dir!;
  }

  /// Menyimpan data JSON (List atau Map) ke file cache lokal
  static Future<void> save(String key, dynamic jsonContent) async {
    if (kIsWeb) return;
    try {
      final dir = await _cacheDir;
      final file = File('${dir.path}/$key.json');
      await file.writeAsString(jsonEncode(jsonContent), flush: true);
    } catch (e) {
      debugPrint('CacheStorage.save error [$key]: $e');
    }
  }

  /// Membaca data JSON dari file cache lokal
  static Future<dynamic> load(String key) async {
    if (kIsWeb) return null;
    try {
      final dir = await _cacheDir;
      final file = File('${dir.path}/$key.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          return jsonDecode(content);
        }
      }
    } catch (e) {
      debugPrint('CacheStorage.load error [$key]: $e');
    }
    return null;
  }

  /// Menghapus cache berdasarkan key tertentu
  static Future<void> clear(String key) async {
    if (kIsWeb) return;
    try {
      final dir = await _cacheDir;
      final file = File('${dir.path}/$key.json');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }

  /// Menghapus seluruh cache data lokal (misal saat logout)
  static Future<void> clearAll() async {
    if (kIsWeb) return;
    try {
      final dir = await _cacheDir;
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
      _dir = null;
    } catch (_) {}
  }
}
