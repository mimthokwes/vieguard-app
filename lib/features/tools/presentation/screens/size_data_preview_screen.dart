import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';

class SizeDataPreviewScreen extends StatelessWidget {
  const SizeDataPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pratinjau Data Ukuran'),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Top Verification Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
              child: const Row(
                children: [
                  Icon(Icons.verified, color: AppColors.primary, size: 16),
                  SizedBox(width: 8),
                  Text('Tervalidasi Otomatis via AI Checker', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  Spacer(),
                  Text('v2.1 Resmi', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // File Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.cardBorder)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: const Color(0xFF16A34A), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.grid_on_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('data_ukuran_smp_brawijaya.xlsx', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            Text('Pesanan: #VG-2024-0891 (SMP Brawijaya)', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                      const AppBadge(label: '100% Valid', type: BadgeType.success),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const [
                        Column(children: [Text('Total Siswa', style: TextStyle(fontSize: 10, color: AppColors.textMuted)), Text('36 Stel', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary))]),
                        Column(children: [Text('Variasi Ukuran', style: TextStyle(fontSize: 10, color: AppColors.textMuted)), Text('S, M, L, XL', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary))]),
                        Column(children: [Text('Kelengkapan', style: TextStyle(fontSize: 10, color: AppColors.textMuted)), Text('Lengkap', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.accentGreen))]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Distribusi Ukuran Seragam Card (4 Kluster)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.cardBorder)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Distribusi Ukuran Seragam', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      Text('4 Kluster', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildClusterBox('S', '10', 'Stel'),
                      const SizedBox(width: 8),
                      _buildClusterBox('M', '18', 'Mayoritas', isMax: true),
                      const SizedBox(width: 8),
                      _buildClusterBox('L', '6', 'Stel'),
                      const SizedBox(width: 8),
                      _buildClusterBox('XL', '2', 'Khusus', isSpecial: true),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Rincian Siswa & Penugasan Table Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.cardBorder)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Rincian Siswa & Penugasan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      AppBadge(label: '7 dari 36', type: BadgeType.info),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
                    child: const Row(
                      children: [
                        SizedBox(width: 30, child: Text('NO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted))),
                        Expanded(flex: 3, child: Text('NAMA SISWA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted))),
                        Expanded(flex: 1, child: Text('UKURAN', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted))),
                        Expanded(flex: 2, child: Text('PERAN', textAlign: TextAlign.end, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  _buildStudentRow('01', 'Ahmad Fadhil P.', 'Pria • TB 164cm', 'M', 'Pasukan'),
                  _buildStudentRow('02', 'Bunga Citra L.', 'Wanita • TB 158cm', 'S', 'Mayoret', isBadgeYellow: true),
                  _buildStudentRow('03', 'Dimas Bagus S.', 'Pria • TB 170cm', 'L', 'Snare Drum'),
                  _buildStudentRow('04', 'Eka Kurniawati', 'Wanita • TB 160cm', 'M', 'Bellyra'),
                  _buildStudentRow('05', 'Farhan Maulana A.', 'Pria • TB 175cm', 'XL', 'Bass Drum 1'),
                  _buildStudentRow('06', 'Gita Maharani', 'Wanita • TB 155cm', 'S', 'Color Guard'),
                  _buildStudentRow('07', 'Hendra Wicaksono', 'Pria • TB 168cm', 'M', 'Brass Section'),

                  const SizedBox(height: 12),
                  const Center(
                    child: Text('Menampilkan 7 dari total 36 data siswa terdaftar', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Workshop Notice Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.primaryBorder)),
              child: const Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Siap Produksi Cutting & Bordir', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        SizedBox(height: 2),
                        Text('Data ini siap dikirim ke workshop untuk pemotongan pola kain (cutting) & pengerjaan bordir nama siswa.', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Bottom Buttons
            AppButton(
              text: 'Unduh Berkas Excel (.xlsx)',
              icon: Icons.download_rounded,
              onPressed: () {},
              isPrimary: true,
              height: 50,
            ),
            const SizedBox(height: 10),
            AppButton(
              text: 'Bagikan Link Pratinjau ke Workshop',
              icon: Icons.share_rounded,
              onPressed: () {},
              isPrimary: false,
              isOutline: true,
              height: 48,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildClusterBox(String sizeLabel, String count, String subtext, {bool isMax = false, bool isSpecial = false}) {
    Color bg = isMax ? AppColors.primary : (isSpecial ? AppColors.accentOrangeBg : Colors.white);
    Color fg = isMax ? Colors.white : AppColors.textPrimary;
    Color border = isMax ? AppColors.primary : (isSpecial ? AppColors.accentOrangeBorder : AppColors.cardBorder);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: isMax ? Colors.white24 : AppColors.primaryLight, borderRadius: BorderRadius.circular(6)),
              child: Text(sizeLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isMax ? Colors.white : AppColors.primary)),
            ),
            const SizedBox(height: 4),
            Text(count, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: fg)),
            Text(subtext, style: TextStyle(fontSize: 9, color: isMax ? Colors.white70 : AppColors.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentRow(String no, String name, String detail, String size, String role, {bool isBadgeYellow = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 30, child: Text(no, style: const TextStyle(fontSize: 12, color: AppColors.textMuted))),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                Text(detail, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(6)),
                child: Text(size, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isBadgeYellow ? AppColors.accentOrangeBg : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  role,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isBadgeYellow ? AppColors.accentOrange : AppColors.textSecondary),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
