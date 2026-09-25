import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';

class RentalStockDetailScreen extends StatelessWidget {
  const RentalStockDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detail Stok Item'),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Showcase Card with Overlay Badges
            Container(
              height: 240,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1578632767115-351597cf2477?auto=format&fit=crop&w=600&q=80'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.8), Colors.transparent, Colors.black.withOpacity(0.6)],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        AppBadge(label: 'Grade A (Sangat Terawat)', type: BadgeType.success),
                        AppBadge(label: 'Koleksi Premiere', type: BadgeType.warning),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('SKU Inventaris', style: TextStyle(fontSize: 10, color: Colors.white70)),
                        Text('#KST-TGD-01', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Title & Category
            Row(
              children: const [
                Expanded(
                  child: Text('Kostum Tari Gandrung Banyuwangi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                ),
                Icon(Icons.verified, color: AppColors.primary, size: 22),
              ],
            ),
            const SizedBox(height: 2),
            const Text('Tradisi Tari Klasik • Busana Pentas & Festival Budaya', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 16),

            // Real-Time Availability Card (Dark Navy Gradient)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF0F2C59)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.rss_feed_rounded, color: AppColors.accentOrange, size: 16),
                          SizedBox(width: 6),
                          Text('KETERSEDIAAN REAL-TIME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 0.8)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(6)),
                        child: const Text('Sync Otomatis', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: const [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Inventaris Koleksi', style: TextStyle(fontSize: 10, color: Colors.white70)),
                          Text('16 Stel Lengkap', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Rasio Siap Pakai', style: TextStyle(fontSize: 10, color: Colors.white70)),
                          Text('25% Available', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.accentGreen)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 3 Stat Boxes
                  Row(
                    children: [
                      _buildAvailabilityStatBox('Di Rak', '4', 'Siap Sewa', Colors.white24, Colors.white),
                      const SizedBox(width: 8),
                      _buildAvailabilityStatBox('Di Luar', '10', 'Disewa Aktif', Colors.white24, Colors.white),
                      const SizedBox(width: 8),
                      _buildAvailabilityStatBox('Servis', '2', 'Cuci / Jahit', AppColors.accentOrange.withOpacity(0.3), AppColors.accentOrange),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Breakdown Stok Unit Size Card
            _buildSectionCard(
              title: 'Breakdown Stok Unit Size',
              subtitle: '4 Variasi Ukuran',
              icon: Icons.aspect_ratio_outlined,
              child: Column(
                children: [
                  _buildSizeBreakdownCard('S', 'Ukuran S (Small)', 'Postur Penari 150-158 cm', '3', '1', '2', '0', isAktif: true),
                  const SizedBox(height: 10),
                  _buildSizeBreakdownCard('M', 'Ukuran M (Medium)', 'Postur Penari 158-165 cm', '6', '2', '3', '1', isAktif: true),
                  const SizedBox(height: 10),
                  _buildSizeBreakdownCard('L', 'Ukuran L (Large)', 'Postur Penari 165-172 cm', '5', '1', '4', '0', isAktif: true),
                  const SizedBox(height: 10),
                  _buildSizeBreakdownCard('XL', 'Ukuran XL (Extra Large)', 'Postur Penari >172 cm', '2', '0', '1', '1', isAktif: false),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Aset & Aksesoris Wajib Card
            _buildSectionCard(
              title: 'Aset & Aksesoris Wajib',
              subtitle: '16 Paket Serasi',
              icon: Icons.layers_outlined,
              badge: const AppBadge(label: '16 Paket Serasi', type: BadgeType.info),
              child: Column(
                children: [
                  _buildAccessoryRow('Mahkota Kuningan Omprok', 'RFID #RF-OMP-9921', '16 Unit'),
                  const SizedBox(height: 8),
                  _buildAccessoryRow('Selendang Cinde Merah Emas', 'Kain Tenun Halus Banyuwangi', '16 Helai'),
                  const SizedBox(height: 8),
                  _buildAccessoryRow('Kipas Tradisional Lipat Emas', 'Bambu Ulir Ukir Manual', '16 Pcs'),
                  const SizedBox(height: 8),
                  _buildAccessoryRow('Pending Sabuk Logam Gandrung', 'Pelapis Logam Anti Karat', '16 Pcs'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Riwayat & Utilisasi Card
            _buildSectionCard(
              title: 'Riwayat & Utilisasi',
              subtitle: 'Lihat Semua >',
              icon: Icons.history_rounded,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total Omset Sewa Item Ini', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                            Text('Rp 14.800.000', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary)),
                          ],
                        ),
                        AppBadge(label: 'Tahun 2024', type: BadgeType.neutral),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildHistoryRow('Sanggar Gayatri', 'Pementasan Festival Gandrung Sewu', '12 Stel', 'Kembali 27 Okt'),
                  const SizedBox(height: 8),
                  _buildHistoryRow('SMP Kartika', 'Pentas Seni Dies Natalis', '2 Stel', 'Selesai 20 Okt'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Bottom Buttons
            AppButton(
              text: 'Update Status & Stok Unit',
              icon: Icons.edit_note_rounded,
              onPressed: () {},
              isPrimary: true,
              height: 50,
            ),
            const SizedBox(height: 10),
            AppButton(
              text: 'Cetak Barcode / QR Label',
              icon: Icons.qr_code_2_rounded,
              onPressed: () {},
              isPrimary: false,
              isOutline: true,
              height: 46,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityStatBox(String label, String count, String subtitle, Color bg, Color textColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 10, color: textColor.withOpacity(0.8))),
            Text(count, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: textColor)),
            Text(subtitle, style: TextStyle(fontSize: 9, color: textColor.withOpacity(0.8))),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
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

  Widget _buildSizeBreakdownCard(
    String sizeLetter,
    String sizeTitle,
    String desc,
    String total,
    String ready,
    String disewa,
    String cuci, {
    bool isAktif = true,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                child: Center(child: Text(sizeLetter, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.primary))),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sizeTitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    Text(desc, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                  ],
                ),
              ),
              AppBadge(label: isAktif ? 'Aktif' : 'Maintenance', type: isAktif ? BadgeType.success : BadgeType.warning),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCountColumn('Total', total, AppColors.textPrimary),
              _buildCountColumn('Ready', ready, AppColors.accentGreen),
              _buildCountColumn('Disewa', disewa, AppColors.primary),
              _buildCountColumn('Cuci', cuci, AppColors.accentOrange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCountColumn(String label, String val, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textMuted)),
        Text(val, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildAccessoryRow(String title, String desc, String qty) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              Text(desc, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
            ],
          ),
          Text(qty, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary)),
        ],
      ),
    );
  }

  Widget _buildHistoryRow(String title, String desc, String qty, String status) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              Text(desc, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(qty, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
              Text(status, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}
