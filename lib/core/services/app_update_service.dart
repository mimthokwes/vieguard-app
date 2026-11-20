import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';

import '../theme/app_theme.dart';

class GithubReleaseInfo {
  final String tagName;
  final String version;
  final String name;
  final String body;
  final String? apkDownloadUrl;
  final String? ipaDownloadUrl;
  final String htmlUrl;

  const GithubReleaseInfo({
    required this.tagName,
    required this.version,
    required this.name,
    required this.body,
    this.apkDownloadUrl,
    this.ipaDownloadUrl,
    required this.htmlUrl,
  });

  factory GithubReleaseInfo.fromJson(Map<String, dynamic> json) {
    final tagName = (json['tag_name'] as String? ?? '').trim();
    final rawVersion = tagName.replaceFirst(RegExp(r'^[vV]'), '');
    final version = rawVersion.split('+').first;
    final assets = (json['assets'] as List<dynamic>?) ?? [];

    String? apkUrl;
    String? ipaUrl;

    for (final asset in assets) {
      if (asset is Map<String, dynamic>) {
        final name = (asset['name'] as String? ?? '').toLowerCase();
        final url = asset['browser_download_url'] as String?;
        if (name.endsWith('.apk')) {
          apkUrl = url;
        } else if (name.endsWith('.ipa')) {
          ipaUrl = url;
        }
      }
    }

    return GithubReleaseInfo(
      tagName: tagName,
      version: version,
      name: json['name'] as String? ?? tagName,
      body: json['body'] as String? ?? '',
      apkDownloadUrl: apkUrl,
      ipaDownloadUrl: ipaUrl,
      htmlUrl: json['html_url'] as String? ?? '',
    );
  }
}

class AppUpdateService {
  AppUpdateService._();

  static const String _githubRepo = 'mimthokwes/vieguard-app';
  static bool _hasCheckedThisSession = false;

  /// Membaca versi aplikasi saat ini dari .env atau fallback default
  static String getCurrentVersion() {
    final envVersion = dotenv.env['APP_VERSION'];
    if (envVersion != null && envVersion.isNotEmpty) {
      return envVersion.replaceFirst(RegExp(r'^[vV]'), '').split('+').first.trim();
    }
    return '1.1.2';
  }

  /// Membandingkan apakah versi remote lebih baru dibandingkan versi saat ini
  static bool isNewerVersion(String latest, String current) {
    try {
      final cleanLatest = latest.replaceFirst(RegExp(r'^[vV]'), '').trim();
      final cleanCurrent = current.replaceFirst(RegExp(r'^[vV]'), '').trim();

      final baseLatest = cleanLatest.split('+').first;
      final baseCurrent = cleanCurrent.split('+').first;

      final latestMain = baseLatest.split('-').first;
      final currentMain = baseCurrent.split('-').first;

      final lParts = latestMain.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final cParts = currentMain.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      while (lParts.length < 3) {
        lParts.add(0);
      }
      while (cParts.length < 3) {
        cParts.add(0);
      }

      for (int i = 0; i < 3; i++) {
        if (lParts[i] > cParts[i]) return true;
        if (lParts[i] < cParts[i]) return false;
      }

      // Jika nomor mayor.minor.patch sama:
      // Versi rilis stabil lebih baru daripada versi pre-release
      final isCurrentPre = baseCurrent.contains('-');
      final isLatestPre = baseLatest.contains('-');
      if (isCurrentPre && !isLatestPre) {
        return true;
      }

      return false;
    } catch (_) {
      return false;
    }
  }

  /// Menghapus file instalasi .apk / .ipa lama dari direktori cache aplikasi agar tidak menumpuk
  static Future<void> cleanupOldUpdateFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final updateDir = Directory('${tempDir.path}/vieguard_updates');
      if (await updateDir.exists()) {
        final entities = updateDir.listSync();
        for (final entity in entities) {
          if (entity is File) {
            final lower = entity.path.toLowerCase();
            if (lower.endsWith('.apk') || lower.endsWith('.ipa')) {
              await entity.delete();
              debugPrint('[AppUpdate] Berkas instalasi lama dihapus: ${entity.path}');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('[AppUpdate] Gagal membersihkan berkas lama: $e');
    }
  }

  /// Mengambil informasi rilis terbaru dari GitHub Releases API
  static Future<GithubReleaseInfo?> fetchLatestRelease() async {
    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 10),
          headers: {'Accept': 'application/vnd.github.v3+json'},
        ),
      );

      final response = await dio.get(
        'https://api.github.com/repos/$_githubRepo/releases/latest',
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return GithubReleaseInfo.fromJson(response.data as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('[AppUpdate] Error mengambil rilis GitHub: $e');
    }
    return null;
  }

  /// Pengecekan pembaruan saat pertama kali masuk ke dashboard / beranda
  static Future<void> checkForUpdateOnBeranda(BuildContext context, {bool force = false}) async {
    if (_hasCheckedThisSession && !force) return;
    _hasCheckedThisSession = true;

    // Bersihkan berkas unduhan lama secara otomatis saat startup
    await cleanupOldUpdateFiles();

    final release = await fetchLatestRelease();
    if (release == null) return;

    final currentVersion = getCurrentVersion();
    final hasUpdate = isNewerVersion(release.version, currentVersion);

    if (hasUpdate && context.mounted) {
      showUpdateDialog(context, release: release, currentVersion: currentVersion);
    }
  }

  /// Menampilkan popup dialog pembaruan
  static void showUpdateDialog(
    BuildContext context, {
    required GithubReleaseInfo release,
    required String currentVersion,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        double progress = 0.0;
        bool isDownloading = false;
        String statusText = 'Mengunduh...';

        return PopScope(
          canPop: !isDownloading,
          child: StatefulBuilder(
            builder: (context, setState) {
              return Dialog(
                backgroundColor: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 6,
                insetPadding: const EdgeInsets.symmetric(horizontal: 32),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Judul Dialog
                      const Text(
                        'Pembaharuan',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Baris Versi Saat Ini -> Versi Terbaru
                      if (!isDownloading) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'v$currentVersion',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                'v${release.version}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        // Indikator Pengunduhan
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              statusText,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: progress > 0 ? progress : null,
                                minHeight: 7,
                                backgroundColor: AppColors.border,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '${(progress * 100).toInt()}%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 22),

                      // Tombol Aksi
                      if (!isDownloading) ...[
                        Row(
                          children: [
                            // Tombol Lewati di sebelah kiri (Text button murni tanpa background)
                            Expanded(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(dialogContext).pop();
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.textSecondary,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Lewati',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Tombol Perbaharui di sebelah kanan (Warna maroon VieGuard, teks putih)
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                onPressed: () async {
                                  final downloadUrl = defaultTargetPlatform == TargetPlatform.iOS
                                      ? release.ipaDownloadUrl
                                      : release.apkDownloadUrl;

                                  if (downloadUrl == null || downloadUrl.isEmpty) {
                                    setState(() {
                                      statusText = 'Berkas pembaruan belum tersedia.';
                                    });
                                    return;
                                  }

                                  setState(() {
                                    isDownloading = true;
                                    statusText = 'Mengunduh pembaruan...';
                                  });

                                  await _startDownloadAndInstall(
                                    downloadUrl: downloadUrl,
                                    version: release.version,
                                    onProgress: (p) {
                                      setState(() {
                                        progress = p;
                                      });
                                    },
                                    onError: (err) {
                                      setState(() {
                                        isDownloading = false;
                                        statusText = 'Gagal: $err';
                                      });
                                    },
                                    onComplete: () {
                                      if (Navigator.of(dialogContext).canPop()) {
                                        Navigator.of(dialogContext).pop();
                                      }
                                    },
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Perbaharui',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Eksekusi pengunduhan berkas dan peluncuran instalasi APK
  static Future<void> _startDownloadAndInstall({
    required String downloadUrl,
    required String version,
    required ValueChanged<double> onProgress,
    required ValueChanged<String> onError,
    required VoidCallback onComplete,
  }) async {
    try {
      // 1. Hapus berkas instalasi lama sebelum memulai unduhan baru
      await cleanupOldUpdateFiles();

      // 2. Siapkan direktori penyimpanan lokal sementara
      final tempDir = await getTemporaryDirectory();
      final updateDir = Directory('${tempDir.path}/vieguard_updates');
      if (!await updateDir.exists()) {
        await updateDir.create(recursive: true);
      }

      final fileName = defaultTargetPlatform == TargetPlatform.iOS
          ? 'vieguard_v$version.ipa'
          : 'vieguard_v$version.apk';
      final savePath = '${updateDir.path}/$fileName';

      // 3. Unduh berkas pembaruan dari GitHub Releases
      final dio = Dio();
      await dio.download(
        downloadUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            onProgress(received / total);
          }
        },
      );

      // 4. Proses Instalasi APK untuk Android
      if (defaultTargetPlatform == TargetPlatform.android) {
        if (await Permission.requestInstallPackages.isDenied) {
          await Permission.requestInstallPackages.request();
        }

        final openResult = await OpenFilex.open(
          savePath,
          type: 'application/vnd.android.package-archive',
        );

        if (openResult.type != ResultType.done) {
          debugPrint('[AppUpdate] Hasil OpenFilex: ${openResult.message}');
        }
      }

      onComplete();
    } catch (e) {
      debugPrint('[AppUpdate] Kesalahan proses pembaruan: $e');
      onError(e.toString());
    }
  }
}
