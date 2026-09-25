import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/custom_app_bar.dart';

import '../../../../core/providers/report_provider.dart';

class BusinessReportScreen extends StatefulWidget {
  const BusinessReportScreen({super.key});

  @override
  State<BusinessReportScreen> createState() => _BusinessReportScreenState();
}

class _BusinessReportScreenState extends State<BusinessReportScreen> {
  final ReportProvider _reportProvider = ReportProvider();

  @override
  void initState() {
    super.initState();
    _reportProvider.fetchSummary();
    _reportProvider.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomHeaderAppBar(subtitle: 'Laporan & Analitik Bisnis'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Filter Bar & Export PDF Button
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.cardBorder)),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_month, size: 18, color: AppColors.primary),
                            SizedBox(width: 8),
                            Text('Bulan Ini (Okt 2024)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          ],
                        ),
                        Icon(Icons.arrow_drop_down, color: AppColors.textMuted),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Laporan PDF berhasil diunduh.')));
                  },
                  icon: const Icon(Icons.cloud_download_outlined, size: 16, color: AppColors.primary),
                  label: const Text('Unduh', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Target Q4 Progress Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.accentOrangeBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.accentOrangeBorder)),
              child: const Row(
                children: [
                  Icon(Icons.show_chart_rounded, color: AppColors.primary, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text('Target Omset Q4 tercapai 86.4%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  ),
                  AppBadge(label: 'On-track ✓', type: BadgeType.warning),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 4 Key Metrics (2x2 Grid)
            Row(
              children: [
                _buildMetricCard(
                  title: 'Total Omset',
                  value: 'Rp 64,85M',
                  growth: '+18.4%',
                  subtext: 'Konveksi 68% • Sewa 32%',
                  isGreenGrowth: true,
                ),
                const SizedBox(width: 10),
                _buildMetricCard(
                  title: 'Pesanan Masuk',
                  value: '48 Pesanan',
                  growth: '+8 unit',
                  subtext: '42 Selesai • 6 Pending',
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildMetricCard(
                  title: 'Utilisasi Sewa',
                  value: '82.5%',
                  growth: 'Musim Pentas',
                  subtext: 'Kapasitas Maksimal',
                  isBadgeTag: true,
                ),
                const SizedBox(width: 10),
                _buildMetricCard(
                  title: 'Akurasi QC',
                  value: '98.2%',
                  growth: 'Bebas Retur',
                  subtext: 'Grade Standar Militer',
                  isBadgeTag: true,
                  isBadgeGreen: true,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Komposisi Pendapatan Card
            _buildSectionCard(
              title: 'Komposisi Pendapatan',
              subtitle: 'Distribusi portofolio konveksi vs rental',
              icon: Icons.donut_large_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Multi-color Progress Stack Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox(
                      height: 14,
                      child: Row(
                        children: [
                          Expanded(flex: 42, child: Container(color: const Color(0xFF1E3A8A))),
                          Expanded(flex: 26, child: Container(color: const Color(0xFF2563EB))),
                          Expanded(flex: 22, child: Container(color: const Color(0xFFF59E0B))),
                          Expanded(flex: 10, child: Container(color: const Color(0xFF10B981))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Legend Grid (2 columns)
                  Row(
                    children: [
                      Expanded(child: _buildLegendItem('Konveksi Standar', '42% (Rp 27.2M)', const Color(0xFF1E3A8A))),
                      Expanded(child: _buildLegendItem('Custom Batch', '26% (Rp 16.8M)', const Color(0xFF2563EB))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _buildLegendItem('Rental Tari & Seni', '22% (Rp 14.2M)', const Color(0xFFF59E0B))),
                      Expanded(child: _buildLegendItem('Rental Drumband', '10% (Rp 6.4M)', const Color(0xFF10B981))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Katalog Terlaris Card
            _buildSectionCard(
              title: 'Katalog Terlaris',
              subtitle: '3 produk penyumbang omset tertinggi',
              icon: Icons.star_outline_rounded,
              badge: const Text('Lihat Semua', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
              child: Column(
                children: [
                  _buildTopProductItem('Paket Drumband Gita Bahari', '14 Kontrak Pesanan', 'Rp 28.5M', 'Top Revenue #1', 'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?auto=format&fit=crop&w=150&q=80'),
                  const SizedBox(height: 10),
                  _buildTopProductItem('Kostum Gandrung Banyuwangi', '18x Penyewaan Event', 'Rp 14.8M', 'Musim Pentas', 'https://images.unsplash.com/photo-1578632767115-351597cf2477?auto=format&fit=crop&w=150&q=80'),
                  const SizedBox(height: 10),
                  _buildTopProductItem('Wearpack American Drill Pro', '4 Institusi Korporasi', 'Rp 21.5M', 'Repeat Order', 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?auto=format&fit=crop&w=150&q=80'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Efisiensi Operasional Card
            _buildSectionCard(
              title: 'Efisiensi Operasional',
              subtitle: 'Kinerja Prima',
              icon: Icons.speed_rounded,
              badge: const AppBadge(label: 'Kinerja Prima', type: BadgeType.success),
              child: Column(
                children: [
                  _buildEfficiencyItem(Icons.precision_manufacturing_outlined, 'Waktu Produksi Konveksi', '14 Hari Kerja', 'Sesuai SLA'),
                  const SizedBox(height: 8),
                  _buildEfficiencyItem(Icons.bolt_rounded, 'Verifikasi Pembayaran', '18 Menit', 'Sangat Cepat'),
                  const SizedBox(height: 8),
                  _buildEfficiencyItem(Icons.history_rounded, 'Pengembalian Tepat Waktu', '94.0%', 'Disiplin Tinggi'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            AppButton(
              text: 'Kirim Laporan Mingguan ke Direksi',
              icon: Icons.mail_outline_rounded,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Laporan mingguan terenkripsi dikirim ke direksi.')));
              },
              isPrimary: true,
              height: 50,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String growth,
    required String subtext,
    bool isGreenGrowth = false,
    bool isBadgeTag = false,
    bool isBadgeGreen = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.cardBorder)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                if (!isBadgeTag)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: isGreenGrowth ? AppColors.accentGreenBg : AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
                    child: Text(growth, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isGreenGrowth ? AppColors.accentGreen : AppColors.primary)),
                  )
                else
                  AppBadge(label: growth, type: isBadgeGreen ? BadgeType.success : BadgeType.warning),
              ],
            ),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(subtext, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    Widget? badge,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.cardBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                child: Icon(icon, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              ),
              if (badge != null) badge,
            ],
          ),
          const Divider(height: 24, color: AppColors.cardBorder),
          child,
        ],
      ),
    );
  }

  Widget _buildLegendItem(String title, String val, Color dotColor) {
    return Row(
      children: [
        CircleAvatar(radius: 4, backgroundColor: dotColor),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            Text(val, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ],
        ),
      ],
    );
  }

  Widget _buildTopProductItem(String title, String sub, String price, String badge, String imgUrl) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(image: NetworkImage(imgUrl), fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                Text(sub, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.primary)),
              Text(badge, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.accentGreen)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEfficiencyItem(IconData icon, String title, String val, String badge) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                Text(val, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
            child: Text(badge, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}
