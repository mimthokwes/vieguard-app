import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../theme/app_theme.dart';

/// Service state management untuk mengunduh, menyimpan, dan meng-cache gambar
/// di memori dan penyimpanan lokal agar tidak perlu fetch berulang kali.
class ImageCacheService {
  ImageCacheService._();

  static Directory? _cacheDir;
  static final Map<String, Uint8List> _memoryCache = {};
  static final Map<String, Future<Uint8List?>> _inFlight = {};
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 20),
  ));

  static Future<Directory> get _dir async {
    if (_cacheDir == null) {
      final base = await getApplicationSupportDirectory();
      final folder = Directory('${base.path}/vg_img_cache');
      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }
      _cacheDir = folder;
    }
    return _cacheDir!;
  }

  static String _keyToFilename(String url) {
    var hash = 5381;
    for (final b in utf8.encode(url)) {
      hash = ((hash << 5) + hash) + b;
    }
    final safeHash = (hash & 0x7FFFFFFF).toRadixString(16);
    final ext = url.split('?').first.split('.').last.toLowerCase();
    final cleanExt = (ext == 'png' || ext == 'webp' || ext == 'jpeg') ? ext : 'jpg';
    return 'vg_${safeHash}_${url.length}.$cleanExt';
  }

  /// Mendapatkan bytes gambar: cek memori -> cek disk file -> unduh dari network
  static Future<Uint8List?> getImageBytes(String url) async {
    if (url.trim().isEmpty) return null;

    // 1. Cek memory cache (instan)
    if (_memoryCache.containsKey(url)) {
      return _memoryCache[url];
    }

    // Web handling
    if (kIsWeb) return null;

    // 2. Hindari request duplikat jika sedang mengunduh URL yang sama
    if (_inFlight.containsKey(url)) {
      return await _inFlight[url];
    }

    final future = _loadFromDiskOrNetwork(url);
    _inFlight[url] = future;
    try {
      final bytes = await future;
      if (bytes != null && bytes.isNotEmpty) {
        // Simpan ke memory cache (batasi jumlah item memory jika perlu)
        if (_memoryCache.length > 200) {
          _memoryCache.remove(_memoryCache.keys.first);
        }
        _memoryCache[url] = bytes;
      }
      return bytes;
    } finally {
      _inFlight.remove(url);
    }
  }

  /// Prefetch gambar di background agar saat dibuka sudah siap
  static Future<void> prefetch(String? url) async {
    if (url == null || url.trim().isEmpty) return;
    await getImageBytes(url);
  }

  /// Prefetch banyak gambar sekaligus
  static void prefetchAll(List<String?> urls) {
    for (final u in urls) {
      if (u != null && u.trim().isNotEmpty) {
        prefetch(u);
      }
    }
  }

  static Future<Uint8List?> _loadFromDiskOrNetwork(String url) async {
    try {
      final dir = await _dir;
      final file = File('${dir.path}/${_keyToFilename(url)}');

      // 3. Cek disk cache lokal
      if (await file.exists() && await file.length() > 0) {
        return await file.readAsBytes();
      }

      // 4. Unduh dari jaringan
      final response = await _dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      final data = response.data;
      if (data != null && data.isNotEmpty) {
        final bytes = Uint8List.fromList(data);
        // Simpan ke disk lokal secara asinkron
        file.writeAsBytes(bytes, flush: true).ignore();
        return bytes;
      }
    } catch (e) {
      debugPrint('ImageCacheService download error for $url: $e');
    }
    return null;
  }

  /// Menghapus seluruh cache gambar lokal
  static Future<void> clearCache() async {
    _memoryCache.clear();
    if (kIsWeb) return;
    try {
      final dir = await _dir;
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
      _cacheDir = null;
    } catch (_) {}
  }
}

/// Widget gambar yang otomatis menggunakan caching lokal offline & memory
class VgImage extends StatefulWidget {
  final String? url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const VgImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.errorBuilder,
  });

  @override
  State<VgImage> createState() => _VgImageState();
}

class _VgImageState extends State<VgImage> {
  Uint8List? _bytes;
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(covariant VgImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    final url = widget.url;
    if (url == null || url.trim().isEmpty) {
      if (mounted) setState(() => _bytes = null);
      return;
    }

    if (kIsWeb) return; // Web gunakan Image.network langsung

    // Cek instant memory cache dulu
    if (ImageCacheService._memoryCache.containsKey(url)) {
      final cachedBytes = ImageCacheService._memoryCache[url];
      if (mounted) {
        setState(() {
          _bytes = cachedBytes;
          _isLoading = false;
          _hasError = false;
        });
      } else {
        _bytes = cachedBytes;
      }
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final bytes = await ImageCacheService.getImageBytes(url);
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _bytes = bytes;
      _hasError = bytes == null || bytes.isEmpty;
    });
  }

  Widget _defaultPlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: AppColors.beigeSoft,
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, color: AppColors.textSecondary, size: 24),
    );
  }

  @override
  Widget build(BuildContext context) {
    final url = widget.url;
    if (url == null || url.trim().isEmpty) {
      return widget.placeholder ?? _defaultPlaceholder();
    }

    // Web handling
    if (kIsWeb) {
      return Image.network(
        url,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        errorBuilder: widget.errorBuilder ?? (context, error, stackTrace) => widget.placeholder ?? _defaultPlaceholder(),
      );
    }

    if (_hasError) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(context, Exception('Image failed'), null);
      }
      return widget.placeholder ?? _defaultPlaceholder();
    }

    if (_bytes != null) {
      return Image.memory(
        _bytes!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
      );
    }

    return widget.placeholder ?? _defaultPlaceholder();
  }
}
