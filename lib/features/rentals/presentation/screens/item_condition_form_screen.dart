import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';

class ItemConditionFormScreen extends StatefulWidget {
  const ItemConditionFormScreen({super.key});

  @override
  State<ItemConditionFormScreen> createState() => _ItemConditionFormScreenState();
}

class _ItemConditionFormScreenState extends State<ItemConditionFormScreen> {
  bool _picAgreement = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Catat Kondisi Barang'),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header Info Card
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
                    children: const [
                      Text('#RENT-2024-0412', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      AppBadge(label: 'Auto-Sync On', type: BadgeType.info),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Sanggar Tari Gayatri Surabaya', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  const Text('Inspeksi Pengembalian 12 Stel Kostum Gandrung', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 14, color: AppColors.textMuted),
                      SizedBox(width: 4),
                      Text('Masuk: Hari ini, 14:20 WIB • Petugas: Indra R.', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Summary Stat Counters Row
            Row(
              children: [
                _buildSummaryCounterCard('11', 'Baik & Lengkap', Icons.check_circle_outline, AppColors.accentGreen, AppColors.accentGreenBg),
                const SizedBox(width: 10),
                _buildSummaryCounterCard('1', 'Ada Noda/Rusak', Icons.warning_amber_rounded, AppColors.accentOrange, AppColors.accentOrangeBg),
                const SizedBox(width: 10),
                _buildSummaryCounterCard('0', 'Barang Hilang', Icons.search_off_rounded, AppColors.textMuted, const Color(0xFFF1F5F9)),
              ],
            ),
            const SizedBox(height: 16),

            // Rincian Fisik Pakaian & Properti Card
            _buildSectionCard(
              title: 'Rincian Fisik Pakaian & Properti',
              subtitle: '3 Kelompok Unit',
              icon: Icons.checklist_rtl_outlined,
              child: Column(
                children: [
                  // Group 1: Good Condition
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.cardBorder)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check_circle, size: 18, color: AppColors.accentGreen),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text('11x Kostum Gandrung Kondisi Prima', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            ),
                            const AppBadge(label: 'Lolos', type: BadgeType.success),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text('Ukuran: S (3), M (5), XL (3)', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: AppColors.accentGreenBg, borderRadius: BorderRadius.circular(8)),
                          child: const Row(
                            children: [
                              Icon(Icons.check, size: 14, color: AppColors.accentGreen),
                              SizedBox(width: 6),
                              Text('Kain utuh, manik-manik lengkap, aroma segar.', style: TextStyle(fontSize: 11, color: AppColors.accentGreen, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Group 2: Damaged / Needs Laundry
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.accentOrangeBorder)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.accentOrange),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text('1x Kostum Ukuran L', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            ),
                            const AppBadge(label: 'Ringan (Laundry & Jahit)', type: BadgeType.warning),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text('Noda Make-up & Jahitan Kerah Kendur', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.accentRed)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.build_outlined, size: 14, color: AppColors.primary),
                                  SizedBox(width: 6),
                                  Text('Estimasi Biaya Perbaikan', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Rp 75.000', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.accentRed)),
                                  Text('Potong dari deposit', style: TextStyle(fontSize: 9, color: AppColors.textMuted)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text('Bukti Foto Kerusakan (2 File)', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _buildDamagePhoto('Kerah Noda Bedak', 'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?auto=format&fit=crop&w=150&q=80'),
                            const SizedBox(width: 6),
                            _buildDamagePhoto('Kancing Lepas', 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?auto=format&fit=crop&w=150&q=80'),
                            const SizedBox(width: 6),
                            Container(
                              width: 70,
                              height: 60,
                              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo_outlined, size: 16, color: AppColors.primary),
                                  Text('+ Foto', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Group 3: Accessories 100% Intact
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.cardBorder)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check_circle, size: 18, color: AppColors.accentGreen),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text('Aksesoris Mahkota Omprok & Kipas', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            ),
                            const AppBadge(label: '100% Bebas Cacat', type: BadgeType.success),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text('12 Pasang Lengkap (Omprok Kulit & Kipas Gandrung)', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Rekonsiliasi Uang Jaminan Card
            _buildSectionCard(
              title: 'Rekonsiliasi Uang Jaminan',
              subtitle: 'Kalkulasi refund deposit',
              icon: Icons.account_balance_wallet_outlined,
              child: Column(
                children: [
                  _buildReconciliationRow('Deposit Ditahan Awal', 'Rp 500.000'),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Text('Denda Keterlambatan', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          SizedBox(width: 6),
                          AppBadge(label: 'Tepat Waktu', type: BadgeType.success),
                        ],
                      ),
                      const Text('Rp 0', style: TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _buildReconciliationRow('Potongan Perbaikan / Laundry', '- Rp 75.000', isRed: true),
                  const Divider(height: 20, color: AppColors.cardBorder),

                  // Total Refund Box
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E3A8A), Color(0xFF0F2C59)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('TOTAL DEPOSIT DIKEMBALIKAN', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white70)),
                            SizedBox(height: 2),
                            Text('Ditransfer dalam 1×24 jam', style: TextStyle(fontSize: 10, color: Colors.white70)),
                          ],
                        ),
                        Text('Rp 425.000', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                    child: const Row(
                      children: [
                        Icon(Icons.credit_card_rounded, size: 18, color: AppColors.primary),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Bank BCA • Auto-Verified', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                            Text('088-291-3819 a/n Ni Made Sukmawati', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // PIC Agreement Checkbox Tile
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.cardBorder)),
              child: Row(
                children: [
                  Checkbox(
                    value: _picAgreement,
                    activeColor: AppColors.primary,
                    onChanged: (val) => setState(() => _picAgreement = val ?? false),
                  ),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'PIC Penyewa menyetujui hasil inspeksi fisik, dokumentasi foto noda, dan pemotongan saldo jaminan sebesar Rp 75.000.',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            AppButton(
              text: 'Konfirmasi & Refund Deposit',
              icon: Icons.verified_rounded,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Inspeksi fisik disimpan & refund deposit Rp 425.000 telah diproses!')),
                );
              },
              isSuccess: true,
              height: 50,
            ),
            const SizedBox(height: 10),
            Center(
              child: TextButton(
                onPressed: () {},
                child: const Text('Simpan Draft Pengecekan', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCounterCard(String count, String label, IconData icon, Color color, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(count, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
            const SizedBox(height: 2),
            Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
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

  Widget _buildDamagePhoto(String label, String url) {
    return Expanded(
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
        ),
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          color: Colors.black54,
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 8, color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildReconciliationRow(String label, String value, {bool isRed = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isRed ? AppColors.accentRed : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
