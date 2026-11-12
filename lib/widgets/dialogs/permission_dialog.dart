import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/services/app_permission_service.dart';
import '../../core/services/local_notification_service.dart';
import '../../core/theme/app_theme.dart';
import '../vg/vg_ui.dart';

class PermissionDialog extends StatelessWidget {
  const PermissionDialog({super.key});

  /// Tampilkan bottom sheet perizinan jika belum pernah ditampilkan
  static Future<void> showIfNeeded(BuildContext context) async {
    final prompted = await AppPermissionService.hasPromptedInitial();
    if (prompted) return;

    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PermissionDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Icon Shield + Judul
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.maroonBright,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.shield_outlined, color: AppColors.goldLight, size: 26),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Izin Akses Aplikasi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Vieguard Owner & Admin',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              'Agar operasional pesanan dan komunikasi dengan pelanggan berjalan lancar, mohon aktifkan izin akses perangkat berikut:',
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),

            // Daftar Izin
            _PermissionTile(
              icon: Icons.notifications_active_outlined,
              title: 'Push Notifikasi Handphone',
              description: 'Pemberitahuan instan saat ada pesanan baru, pesan pelanggan, dan pembayaran.',
            ),
            const SizedBox(height: 12),
            _PermissionTile(
              icon: Icons.camera_alt_outlined,
              title: 'Kamera Perangkat',
              description: 'Mengambil foto progres pengerjaan workshop dan dokumentasi serah terima.',
            ),
            const SizedBox(height: 12),
            _PermissionTile(
              icon: Icons.folder_open_rounded,
              title: 'Penyimpanan & File Galeri',
              description: 'Memilih file desain pesanan custom, spreadsheet ukuran, dan bukti transfer.',
            ),
            const SizedBox(height: 22),

            // Tombol Aksi
            Row(
              children: [
                Expanded(
                  child: VgButton(
                    label: 'Nanti Saja',
                    style: VgButtonStyle.soft,
                    height: 44,
                    onPressed: () async {
                      await AppPermissionService.markPrompted();
                      if (context.mounted) Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: VgButton(
                    label: 'Izinkan Akses Sekarang',
                    style: VgButtonStyle.maroon,
                    height: 44,
                    onPressed: () async {
                      Navigator.pop(context);
                      final statuses = await AppPermissionService.requestAllPermissions();

                      // Jika notifikasi diizinkan, kirimkan notifikasi sambutan untuk uji coba
                      final notifStatus = statuses[Permission.notification] == PermissionStatus.granted ||
                          statuses.values.any((s) => s == PermissionStatus.granted || s == PermissionStatus.limited);
                      if (notifStatus) {
                        await LocalNotificationService.show(
                          id: 1001,
                          title: '🔔 Notifikasi Vieguard Aktif',
                          body: 'Pesanan baru dan pesan dari pelanggan akan otomatis muncul di handphone Anda.',
                          channelId: LocalNotificationService.channelGeneralId,
                          channelName: LocalNotificationService.channelGeneralName,
                        );
                      }

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Izin akses aplikasi telah diperbarui.'),
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _PermissionTile({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.beigeSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.goldLight.withValues(alpha: 0.8)),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
