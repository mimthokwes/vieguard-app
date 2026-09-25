import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../reports/presentation/screens/business_report_screen.dart';
import '../../../rentals/presentation/screens/rental_stock_management_screen.dart';
import '../../../tools/presentation/screens/excel_template_info_screen.dart';

import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/store_provider.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final AuthProvider _authProvider = AuthProvider();
  final StoreProvider _storeProvider = StoreProvider();
  bool _autoReceiveOrders = true;
  bool _whatsappIntegration = true;

  @override
  void initState() {
    super.initState();
    _authProvider.loadProfile();
    _storeProvider.fetchProfile();
    _authProvider.addListener(() {
      if (mounted) setState(() {});
    });
    _storeProvider.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomHeaderAppBar(subtitle: 'Akun Admin & Pengaturan'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Card Header
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  // Blue Header background
                  Container(
                    height: 70,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1E3A8A), Color(0xFF0F2C59)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                    ),
                    alignment: Alignment.topRight,
                    padding: const EdgeInsets.all(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                      child: const Text('Sesi Terverifikasi', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -30),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 3),
                                  image: const DecorationImage(
                                    image: NetworkImage('https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=200&q=80'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(color: AppColors.accentGreen, shape: BoxShape.circle),
                                  child: const Icon(Icons.check, size: 12, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                            child: const Text('Senior Operations Administrator', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          ),
                          const SizedBox(height: 6),
                          const Text('Siti Rahmawati, S.E.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                          const Text('Admin ID: VG-ADM-019 • Hub Operasional Surabaya', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          const SizedBox(height: 14),

                          // 3 Performance Stats Columns
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildPerformanceStat('142', 'Pesanan Selesai'),
                                Container(width: 1, height: 30, color: AppColors.primaryBorder),
                                _buildPerformanceStat('99.4%', 'Tingkat Respon'),
                                Container(width: 1, height: 30, color: AppColors.primaryBorder),
                                _buildPerformanceStat('★ 4.9', 'Rating Layanan'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Auto Receive Orders Toggle Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.cardBorder)),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                    child: const Icon(Icons.notifications_active_outlined, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status Penerimaan Otomatis', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        Text('Order masuk langsung dialokasikan ke shift', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  Switch(
                    value: _autoReceiveOrders,
                    activeColor: AppColors.primary,
                    onChanged: (val) => setState(() => _autoReceiveOrders = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // OPERASIONAL & BISNIS Section
            _buildSectionHeader('OPERASIONAL & BISNIS', '4 Modul'),
            const SizedBox(height: 8),

            _buildMenuItem(
              icon: Icons.bar_chart_rounded,
              title: 'Laporan & Analitik Bisnis',
              subtitle: 'Omset, utilisasi sewa &...',
              badgeLabel: 'Bulanan >',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const BusinessReportScreen()));
              },
            ),
            const SizedBox(height: 8),

            _buildMenuItem(
              icon: Icons.warehouse_outlined,
              title: 'Manajemen Inventaris & Rak Gudang',
              subtitle: 'Barcode scan, master SKU &...',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const RentalStockManagementScreen()));
              },
            ),
            const SizedBox(height: 8),

            _buildMenuItem(
              icon: Icons.receipt_long_outlined,
              title: 'Pengaturan Tarif & Template Pesanan',
              subtitle: 'HPP default, margin laba & formulir...',
              onTap: () {},
            ),
            const SizedBox(height: 8),

            _buildMenuItem(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Integrasi WhatsApp & Notifikasi',
              subtitle: 'Auto-sync pesan & template...',
              trailingWidget: Switch(
                value: _whatsappIntegration,
                activeColor: AppColors.accentGreen,
                onChanged: (val) => setState(() => _whatsappIntegration = val),
              ),
            ),
            const SizedBox(height: 20),

            // PENGATURAN & KEAMANAN Section
            _buildSectionHeader('PENGATURAN & KEAMANAN', 'Protokol ISO 27001'),
            const SizedBox(height: 8),

            _buildMenuItem(
              icon: Icons.security_rounded,
              title: 'Keamanan Akun & PIN Otorisasi',
              subtitle: '2-Factor Authentication aktif...',
              onTap: () {},
            ),
            const SizedBox(height: 8),

            _buildMenuItem(
              icon: Icons.sync_rounded,
              title: 'Sinkronisasi Data Offline & Cloud',
              subtitle: 'Sinkron otomatis 2 menit lalu',
              badgeLabel: 'Aktif',
              isBadgeGreen: true,
              onTap: () {},
            ),
            const SizedBox(height: 8),

            _buildMenuItem(
              icon: Icons.description_outlined,
              title: 'Panduan Operasional & Template SOP',
              subtitle: 'Download format Excel ukuran &...',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ExcelTemplateInfoScreen()));
              },
            ),
            const SizedBox(height: 24),

            // Logout Button
            InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Berhasil keluar dari akun admin.')),
                );
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.accentRedBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.accentRed.withOpacity(0.3)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded, color: AppColors.accentRed, size: 18),
                    SizedBox(width: 8),
                    Text('Keluar dari Akun Admin', style: TextStyle(color: AppColors.accentRed, fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // App Build Footer
            const Text('VIEGUARD Admin v2.4.0 (Build 2024.10-PROD)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
            const SizedBox(height: 2),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 10, color: AppColors.textMuted),
                SizedBox(width: 4),
                Text('Sistem Terproteksi Enkripsi End-to-End TLS 1.3', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceStat(String val, String label) {
    return Column(
      children: [
        Text(val, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primary)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String badge) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted, letterSpacing: 0.5)),
        Text(badge, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    String? badgeLabel,
    bool isBadgeGreen = false,
    Widget? trailingWidget,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.cardBorder)),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        trailing: trailingWidget ??
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (badgeLabel != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isBadgeGreen ? AppColors.accentGreenBg : AppColors.accentOrangeBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badgeLabel,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isBadgeGreen ? AppColors.accentGreen : AppColors.accentOrange),
                    ),
                  ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
              ],
            ),
        ),
      ),
    );
  }
}
