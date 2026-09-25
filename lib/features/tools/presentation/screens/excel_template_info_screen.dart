import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';

class ExcelTemplateInfoScreen extends StatelessWidget {
  const ExcelTemplateInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Info Template Excel'),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.cardBorder)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppBadge(label: 'STANDARISASI PRODUKSI V2.4', type: BadgeType.info),
                  const SizedBox(height: 8),
                  const Text('Standar Panduan Data Ukuran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  const Text('Instruksi resmi bagi admin untuk dibagikan kepada pelanggan instansi/sekolah agar format nama dan ukuran seragam serasi dengan mesin workshop.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Icon(Icons.verified, size: 14, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text('Validasi Dropdown', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      SizedBox(width: 12),
                      Icon(Icons.precision_manufacturing, size: 14, color: AppColors.accentOrange),
                      SizedBox(width: 4),
                      Text('Sync CNC Laser Cut', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accentOrange)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Excel Sheet Mockup Container
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.cardBorder)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFF16A34A),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Row(
                          children: [
                            Icon(Icons.grid_on_rounded, color: Colors.white, size: 18),
                            SizedBox(width: 6),
                            Text('template_standar_vieguard_v2.xlsx', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                        AppBadge(label: 'Read Only Preview', type: BadgeType.success),
                      ],
                    ),
                  ),

                  // Table Rows Preview
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
                          child: const Row(
                            children: [
                              SizedBox(width: 30, child: Text('No', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                              Expanded(flex: 3, child: Text('Nama Siswa', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                              Expanded(flex: 2, child: Text('Ukuran Standar', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                              SizedBox(width: 40, child: Text('Qty', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        _buildExcelRow('1', 'Ahmad Fauzan Pratama', 'XL', '1'),
                        _buildExcelRow('2', 'Nadhira Clarissa Putri', 'M', '1'),
                        _buildExcelRow('3', 'Bima Satria Dirgantara', 'Custom !', '1', isCustom: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Tolerance Rule Warning Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.accentOrangeBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.accentOrangeBorder)),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded, color: AppColors.accentOrange, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Aturan Toleransi & Postur Khusus', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        SizedBox(height: 2),
                        Text('Untuk ukuran Custom di luar standar pabrik, cantumkan rincian lingkar dada (LD) & panjang celana/rok secara lengkap pada kolom Keterangan Khusus.', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 5 Tahapan Alur Operasional (SOP)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('5 Tahapan Alur Operasional', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                AppBadge(label: 'SOP Resmi', type: BadgeType.info),
              ],
            ),
            const SizedBox(height: 12),

            _buildSopStep('1', 'Unduh Berkas Template Excel Resmi', 'Gunakan template .xlsx terstandarisasi yang telah dilengkapi validasi dropdown ukuran.', Icons.download_rounded),
            _buildSopStep('2', 'Buka di Microsoft Excel atau Google Sheets', 'Dapat diedit melalui PC sekolah, laptop tata usaha, maupun ponsel smartphone tanpa merusak formula.', Icons.laptop_chromebook_rounded),
            _buildSopStep('3', 'Isi 4 Kolom Wajib', 'Nomor, Nama Lengkap Siswa, Ukuran Terpilih (S/M/L/XL/XXL/Custom), dan Jumlah/Kuantitas pesanan seragam.', Icons.edit_note_rounded),
            _buildSopStep('4', 'Simpan dengan Format Penamaan Jelas', 'Beri nama berkas sesuai format baku sistem automasi pabrik: data_ukuran_[nama_sekolah]_[paket]', Icons.save_as_rounded),
            _buildSopStep('5', 'Unggah Berkas ke Aplikasi', 'Pelanggan mengunggah di form pesanan, atau kirimkan via WhatsApp ke admin untuk sinkronisasi antrean potong instan.', Icons.cloud_upload_rounded, isLast: true),

            const SizedBox(height: 16),

            // Performance Indicator Cards Row
            Row(
              children: [
                Expanded(child: _buildPerfIndicator('3x Lebih Cepat', 'Waktu Pengerjaan', Icons.speed_rounded)),
                const SizedBox(width: 10),
                Expanded(child: _buildPerfIndicator('99.8% Presisi', 'Akurasi Potong', Icons.precision_manufacturing_rounded)),
              ],
            ),
            const SizedBox(height: 24),

            // Action Buttons
            AppButton(
              text: 'Unduh Template Excel Resmi (.xlsx)',
              icon: Icons.download_rounded,
              onPressed: () {},
              isPrimary: true,
              height: 50,
            ),
            const SizedBox(height: 10),
            AppButton(
              text: 'Bagikan Link Template ke Pelanggan via WhatsApp',
              icon: Icons.chat_bubble_outline_rounded,
              onPressed: () {},
              isSuccess: true,
              height: 48,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildExcelRow(String no, String name, String size, String qty, {bool isCustom = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 30, child: Text(no, style: const TextStyle(fontSize: 11, color: AppColors.textMuted))),
          Expanded(flex: 3, child: Text(name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: isCustom ? AppColors.accentOrangeBg : AppColors.primaryLight, borderRadius: BorderRadius.circular(4)),
              child: Text(size, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isCustom ? AppColors.accentOrange : AppColors.primary)),
            ),
          ),
          SizedBox(width: 40, child: Text(qty, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildSopStep(String stepNumber, String title, String desc, IconData icon, {bool isLast = false}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: Center(child: Text(stepNumber, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: AppColors.cardBorder),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.cardBorder)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary))),
                      Icon(icon, size: 16, color: AppColors.primary),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(desc, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerfIndicator(String val, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textMuted)),
              Text(val, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.primary)),
            ],
          ),
        ],
      ),
    );
  }
}
