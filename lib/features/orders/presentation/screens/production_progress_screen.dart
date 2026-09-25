import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';

class ProductionProgressScreen extends StatefulWidget {
  const ProductionProgressScreen({super.key});

  @override
  State<ProductionProgressScreen> createState() => _ProductionProgressScreenState();
}

class _ProductionProgressScreenState extends State<ProductionProgressScreen> {
  int _progressPercentage = 75;
  bool _sendWhatsappNotification = true;
  final TextEditingController _notesController = TextEditingController(
    text: 'Bahan kain utama aman, proses penjahitan lengan dan kerah sedang dikebut oleh 4 penjahit senior.',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Update Progres Produksi'),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
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
                      const Text('Klien Institusi', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.accentOrangeBg, borderRadius: BorderRadius.circular(8)),
                        child: const Row(
                          children: [
                            Icon(Icons.timer_outlined, size: 12, color: AppColors.accentOrange),
                            SizedBox(width: 4),
                            Text('H-4 Deadline (Target 28 Okt)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.accentOrange)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('SMA Citra Bangsa', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  const Text('Seragam Batik Kombinasi & Jas Almamater (#VG-2024-0888)', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 14),

                  // Overall Progress Container
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Akumulasi: Tahap Bordir & Jahit', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                            Text('65%', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primary)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: const LinearProgressIndicator(
                            value: 0.65,
                            minHeight: 8,
                            backgroundColor: Colors.white,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Row(
                          children: [
                            Icon(Icons.check_circle, size: 12, color: AppColors.accentGreen),
                            SizedBox(width: 4),
                            Text('2 dari 5 Tahapan Rampung. Est. Finishing: 27 Okt', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Alur Pengerjaan Workshop Card (Timeline)
            _buildSectionCard(
              title: 'Alur Pengerjaan Workshop',
              subtitle: '5 Fase Mutu',
              icon: Icons.account_tree_outlined,
              child: Column(
                children: [
                  _buildTimelineItem(
                    stepNumber: '1',
                    title: '1. Pola & Pemotongan Kain (Cutting)',
                    desc: 'Pola sizing S-XXL presisi laser cut 120 pasang.\n✓ Selesai pada 20 Okt 2024',
                    percentage: '100%',
                    isDone: true,
                  ),
                  _buildTimelineItem(
                    stepNumber: '2',
                    title: '2. Bordir Komputer Logo Yayasan',
                    desc: 'Badge saku dada dan emblem lengan berdensitas tinggi.\n✓ Selesai pada 22 Okt 2024',
                    percentage: '100%',
                    isDone: true,
                  ),
                  _buildTimelineItem(
                    stepNumber: '3',
                    title: '3. Proses Jahit & Assembling',
                    desc: 'Penggabungan furing dormeuil & jahitan stik balik jas.\n⚙ Sedang Berjalan (Target: 24 Okt)',
                    percentage: '70%',
                    isActive: true,
                  ),
                  _buildTimelineItem(
                    stepNumber: '4',
                    title: '4. Quality Control & Pasang Kancing',
                    desc: 'Inspeksi benang, lubang kancing garuda kuningan.\n⏱ Estimasi: 26 Okt 2024',
                    percentage: 'Antrean',
                    isPending: true,
                  ),
                  _buildTimelineItem(
                    stepNumber: '5',
                    title: '5. Steam Pressing & Polybag',
                    desc: 'Penyetrikaan uap garmen, hanger, & labelling barcode pack.\n⏱ Estimasi: 27 Okt 2024',
                    percentage: 'Menunggu',
                    isPending: true,
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Perbarui Status Hari Ini Form Card
            _buildSectionCard(
              title: 'Perbarui Status Hari Ini',
              subtitle: 'Input log aktivitas produksi harian workshop',
              icon: Icons.edit_calendar_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tahap Pengerjaan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: '3. Proses Jahit & Assembling',
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(value: '3. Proses Jahit & Assembling', child: Text('3. Proses Jahit & Assembling', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                          DropdownMenuItem(value: '4. Quality Control', child: Text('4. Quality Control', style: TextStyle(fontSize: 12))),
                        ],
                        onChanged: (_) {},
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Percentage Input
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Persentase Selesai Tahap Ini', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
                        child: Text('$_progressPercentage %', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primary)),
                      ),
                    ],
                  ),
                  Slider(
                    value: _progressPercentage.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 20,
                    activeColor: AppColors.primary,
                    onChanged: (val) => setState(() => _progressPercentage = val.round()),
                  ),
                  const SizedBox(height: 10),

                  const Text('Kuantitas Selesai', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('90 dari 120 Pcs selesai dijahit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        Icon(Icons.check_box_rounded, color: AppColors.primary, size: 20),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Text('Catatan Workshop & Kendala', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 12),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Dokumentasi Foto Workshop Card
            _buildSectionCard(
              title: 'Dokumentasi Foto Workshop',
              subtitle: 'Bukti autentik hasil jahitan & kerapihan jas',
              icon: Icons.photo_camera_outlined,
              badge: const AppBadge(label: '3 Foto Terlampir', type: BadgeType.success),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: const DecorationImage(
                              image: NetworkImage('https://images.unsplash.com/photo-1594938298603-c8148c4dae35?auto=format&fit=crop&w=400&q=80'),
                              fit: BoxFit.cover,
                            ),
                          ),
                          alignment: Alignment.bottomLeft,
                          padding: const EdgeInsets.all(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(4)),
                            child: const Text('Jahitan Kerah Jas', style: TextStyle(fontSize: 9, color: Colors.white)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: const DecorationImage(
                              image: NetworkImage('https://images.unsplash.com/photo-1507679799987-c73779587ccf?auto=format&fit=crop&w=400&q=80'),
                              fit: BoxFit.cover,
                            ),
                          ),
                          alignment: Alignment.bottomLeft,
                          padding: const EdgeInsets.all(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(4)),
                            child: const Text('90 Unit Terangkai', style: TextStyle(fontSize: 9, color: Colors.white)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    text: '+ Ambil Foto / Unggah Dokumentasi',
                    icon: Icons.add_a_photo_outlined,
                    onPressed: () {},
                    isPrimary: false,
                    isSecondary: true,
                    height: 44,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        const Icon(Icons.send_rounded, color: AppColors.accentGreen, size: 20),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Notifikasi WhatsApp Klien', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                              Text('Kirim update foto & estimasi otomatis ke PIC', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                        Switch(
                          value: _sendWhatsappNotification,
                          activeColor: AppColors.accentGreen,
                          onChanged: (val) => setState(() => _sendWhatsappNotification = val),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            AppButton(
              text: 'Simpan & Publikasikan Progres',
              icon: Icons.cloud_upload_rounded,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Progres produksi berhasil diperbarui & dikirim ke WhatsApp pemesan!')),
                );
              },
              isPrimary: true,
              height: 50,
            ),
            const SizedBox(height: 10),
            Center(
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.support_agent_rounded, size: 16, color: AppColors.textSecondary),
                label: const Text(
                  'Hubungi Supervisor Workshop',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
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

  Widget _buildTimelineItem({
    required String stepNumber,
    required String title,
    required String desc,
    required String percentage,
    bool isDone = false,
    bool isActive = false,
    bool isPending = false,
    bool isLast = false,
  }) {
    Color iconBg = isDone ? AppColors.accentGreen : (isActive ? AppColors.primary : const Color(0xFFE2E8F0));
    Color iconFg = isDone || isActive ? Colors.white : AppColors.textMuted;
    IconData icon = isDone ? Icons.check : (isActive ? Icons.settings : Icons.hourglass_empty);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                child: Icon(icon, color: iconFg, size: 16),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isDone ? AppColors.accentGreen : AppColors.cardBorder,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primaryLight : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isActive ? AppColors.primary : AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isActive ? AppColors.primary : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDone ? AppColors.accentGreenBg : (isActive ? AppColors.primary : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          percentage,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isDone ? AppColors.accentGreen : (isActive ? Colors.white : AppColors.textMuted),
                          ),
                        ),
                      ),
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
}
