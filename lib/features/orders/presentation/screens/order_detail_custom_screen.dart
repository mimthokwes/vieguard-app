import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../chat/presentation/screens/chat_detail_screen.dart';
import '../../../tools/presentation/screens/size_data_preview_screen.dart';
import 'input_custom_price_screen.dart';

class OrderDetailCustomScreen extends StatelessWidget {
  const OrderDetailCustomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detail Pesanan Custom'),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: const NetworkImage('https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=150&q=80'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Status Header Card
            Container(
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AppBadge(label: 'MENUNGGU PENAWARAN HARGA', type: BadgeType.warning),
                      const Text('Dipesan: Hari ini, 09:30', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          '#VG-2024-0895',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(6)),
                        child: const Text('Custom Batch', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(6)),
                        child: const Text('80 Stel', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Target Deadline Box
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text('Target Selesai: ', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        Text('20 Nov 2024', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        Spacer(),
                        Text('Estimasi 25 Hari', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Warning Action Card: Estimasi Biaya Belum Ditentukan
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.accentOrangeBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.accentOrangeBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.notifications_active_rounded, color: AppColors.accentOrange, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Estimasi Biaya Belum Ditentukan',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Harap kalkulasikan bahan & kirim penawaran segera.',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 12),
                        AppButton(
                          text: 'Input Harga Custom',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const InputCustomPriceScreen()),
                            );
                          },
                          isWarning: true,
                          height: 40,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Informasi Pelanggan Card
            _buildSectionCard(
              title: 'Informasi Pelanggan',
              subtitle: 'Data Pemesan & Kontak Resmi',
              icon: Icons.school_outlined,
              child: Column(
                children: [
                  _buildDetailRow(icon: Icons.account_balance_outlined, label: 'Institusi Pemesan', value: 'SMK Negeri 4 Bandung'),
                  const SizedBox(height: 10),
                  _buildDetailRow(icon: Icons.person_outline, label: 'Penanggung Jawab (PIC)', value: 'Ibu Dwi Rahmawati, S.Pd\nKetua Jurusan Teknik Mesin'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        const Icon(Icons.phone, color: AppColors.accentGreen, size: 18),
                        const SizedBox(width: 10),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('WhatsApp / Telepon', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                            Text('+62 813-2245-8899', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          ],
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ChatDetailScreen()),
                            );
                          },
                          icon: const Icon(Icons.chat_bubble_rounded, size: 14, color: Colors.white),
                          label: const Text('Chat', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentGreen,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildDetailRow(icon: Icons.location_on_outlined, label: 'Alamat Pengiriman', value: 'Jl. Kliningan No. 6, Buahbatu, Kota Bandung, Jawa Barat (Gedung Jurusan Mesin)'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Spesifikasi Permintaan Card
            _buildSectionCard(
              title: 'Spesifikasi Permintaan',
              subtitle: 'Detail Konfigurasi Pakaian Kerja',
              icon: Icons.build_circle_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSpecBlock('Kategori & Tipe Produk', 'Wearpack Jurusan Mesin & Bordir Reflektif'),
                  const SizedBox(height: 10),
                  _buildSpecBlock('Bahan Kain Utama', 'American Drill Grade A (Tahan Panas & Percikan Api Ringan)'),
                  const SizedBox(height: 10),
                  _buildSpecBlock('Total Kuantitas', '80 Stel (Kemeja Lengan Panjang + Celana Cargo)'),
                  const SizedBox(height: 10),
                  _buildSpecBlock('Fitur Keamanan & Logo', 'Bordir Komputer HD Logo SMK di dada kiri & punggung, Pita Scotlight Reflektif 3M 2.5cm melingkar di lengan & dada.'),
                  const SizedBox(height: 12),

                  // Catatan Khusus Pelanggan Box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.accentOrangeBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Row(
                          children: [
                            Icon(Icons.format_quote_rounded, size: 16, color: AppColors.accentOrange),
                            SizedBox(width: 4),
                            Text('Catatan Khusus Pelanggan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accentOrange)),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          '"Jahitan double tindas, resleting YKK kuningan anti-karat, kantong pensil khusus di lengan kiri."',
                          style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Data Ukuran Siswa Card
            _buildSectionCard(
              title: 'Data Ukuran Siswa',
              subtitle: 'Batch Rekapitulasi Size Chart',
              icon: Icons.grid_on_outlined,
              badge: const AppBadge(label: 'File Terverifikasi', type: BadgeType.success),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF16A34A),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.grid_on_rounded, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('data_ukuran_smkn4_bandung.xlsx', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                              SizedBox(height: 2),
                              Text('Diupload Hari ini • 09:40 WIB', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                          child: const Text('80 Siswa', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppButton(text: 'Unduh File Excel (.xlsx)', icon: Icons.download_rounded, onPressed: () {}, isPrimary: true, height: 44),
                  const SizedBox(height: 8),
                  AppButton(
                    text: 'Pratinjau Data Ukuran (Preview)',
                    icon: Icons.remove_red_eye_outlined,
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const SizeDataPreviewScreen()));
                    },
                    isPrimary: false,
                    isOutline: true,
                    height: 44,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Lampiran Referensi Desain Card
            _buildSectionCard(
              title: 'Lampiran Referensi Desain',
              subtitle: 'Mockup Visual Pakaian Pesanan',
              icon: Icons.image_outlined,
              badge: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(6)),
                child: const Text('2 Foto', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 160,
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.shade900,
                            borderRadius: BorderRadius.circular(12),
                            image: const DecorationImage(
                              image: NetworkImage('https://images.unsplash.com/photo-1578632767115-351597cf2477?auto=format&fit=crop&w=400&q=80'),
                              fit: BoxFit.cover,
                            ),
                          ),
                          alignment: Alignment.bottomLeft,
                          padding: const EdgeInsets.all(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(6)),
                            child: const Text('Tampak Depan', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          height: 160,
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.shade900,
                            borderRadius: BorderRadius.circular(12),
                            image: const DecorationImage(
                              image: NetworkImage('https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?auto=format&fit=crop&w=400&q=80'),
                              fit: BoxFit.cover,
                            ),
                          ),
                          alignment: Alignment.bottomLeft,
                          padding: const EdgeInsets.all(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(6)),
                            child: const Text('Tampak Belakang', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(color: Color(0xFF1B2A4A), shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Spesifikasi Warna Pola', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                              Text(
                                'Navy Blue (#1B2A4A) + Scotlight Silver & Bordir Emas',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Bottom Actions
            AppButton(
              text: 'Buat & Kirim Penawaran Harga',
              icon: Icons.description_rounded,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const InputCustomPriceScreen()),
                );
              },
              isWarning: true,
              height: 50,
            ),
            const SizedBox(height: 10),
            AppButton(
              text: 'Tolak / Minta Revisi Desain',
              icon: Icons.cancel_outlined,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Permintaan revisi dikirim ke pemesan.')),
                );
              },
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
                    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
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

  Widget _buildDetailRow({required IconData icon, required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpecBlock(String title, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
          const SizedBox(height: 2),
          Text(content, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
