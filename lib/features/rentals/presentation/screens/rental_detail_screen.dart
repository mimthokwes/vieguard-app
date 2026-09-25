import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../chat/presentation/screens/chat_detail_screen.dart';
import 'item_condition_form_screen.dart';

class RentalDetailScreen extends StatelessWidget {
  const RentalDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detail Penyewaan'),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ID Reservasi & Period Card
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
                      const Text('ID RESERVASI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                      const AppBadge(label: 'Hari ke-2 dari 3', type: BadgeType.warning),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text('#RENT-2024-0412', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                      const SizedBox(width: 6),
                      IconButton(
                        icon: const Icon(Icons.copy_rounded, size: 16, color: AppColors.primary),
                        onPressed: () {},
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Periode Sewa Box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('Periode Sewa', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                            Text('Sisa 1 Hari 9 Jam', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: const [
                            Icon(Icons.circle, size: 8, color: AppColors.accentGreen),
                            SizedBox(width: 8),
                            Text('24 Okt 2024, 09:00 WIB', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          ],
                        ),
                        Container(margin: const EdgeInsets.only(left: 3), width: 2, height: 12, color: AppColors.cardBorder),
                        Row(
                          children: const [
                            Icon(Icons.circle, size: 8, color: AppColors.accentOrange),
                            SizedBox(width: 8),
                            Text('27 Okt 2024, 18:00 WIB', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Profil Penyewa Card
            _buildSectionCard(
              title: 'Profil Penyewa',
              subtitle: 'Data Kontak & Agenda',
              icon: Icons.theater_comedy_outlined,
              badge: const AppBadge(label: 'Terverifikasi', type: BadgeType.success),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Sanggar Tari Gayatri Surabaya', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const Text('Ibu Ni Made Sukmawati, S.Sn (Ketua Sanggar)', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatDetailScreen()));
                          },
                          icon: const Icon(Icons.chat_bubble_rounded, size: 16, color: Colors.white),
                          label: const Text('Chat WhatsApp', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentGreen,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.phone, color: AppColors.primary, size: 20),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.edit_location_alt_outlined, size: 18, color: AppColors.primary),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Tujuan & Agenda Acara', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                              Text('Pentas Tari Festival Budaya Jawa Timur di Grand City Mall', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Item Kostum Card
            _buildSectionCard(
              title: 'Item Kostum',
              subtitle: '12 Stel Lengkap + Aksesoris',
              icon: Icons.dry_cleaning_outlined,
              badge: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(6)),
                child: const Text('12 Unit', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Kostum Tari Gandrung', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),

                  AppButton(
                    text: 'Catat Pengembalian & Kondisi Barang',
                    icon: Icons.fact_check_outlined,
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ItemConditionFormScreen()));
                    },
                    isPrimary: true,
                    height: 48,
                  ),
                  const SizedBox(height: 8),
                  AppButton(
                    text: 'Cetak Surat Perjanjian Sewa',
                    icon: Icons.print_outlined,
                    onPressed: () {},
                    isPrimary: false,
                    isOutline: true,
                    height: 44,
                  ),
                  const SizedBox(height: 14),

                  // Included Accessories List
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      children: const [
                        Row(children: [Icon(Icons.circle, size: 6, color: AppColors.accentOrange), SizedBox(width: 8), Text('12x Mahkota Omprok Kuningan Asli (Kondisi Baik)', style: TextStyle(fontSize: 11))]),
                        SizedBox(height: 6),
                        Row(children: [Icon(Icons.circle, size: 6, color: AppColors.accentOrange), SizedBox(width: 8), Text('12x Selendang Sampur Merah Cabai', style: TextStyle(fontSize: 11))]),
                        SizedBox(height: 6),
                        Row(children: [Icon(Icons.circle, size: 6, color: AppColors.accentOrange), SizedBox(width: 8), Text('12x Kipas Bambu Emas Prada Banyuwangi', style: TextStyle(fontSize: 11))]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.accentOrangeBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.accentOrangeBorder),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.shield_outlined, color: AppColors.accentOrange, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Deposit Keamanan Terkunci', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accentOrange)),
                              SizedBox(height: 2),
                              Text('Rp 500.000 ditahan sampai barang kembali lengkap dan lulus inspeksi fisik.', style: TextStyle(fontSize: 11, color: AppColors.textPrimary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Inspeksi Pengeluaran (QC Out) Card
            _buildSectionCard(
              title: 'Inspeksi Pengeluaran (QC Out)',
              subtitle: 'Kondisi serah terima kostum',
              icon: Icons.verified_outlined,
              badge: const AppBadge(label: 'Approved', type: BadgeType.success),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                    child: const Row(
                      children: [
                        Icon(Icons.badge_outlined, size: 18, color: AppColors.primary),
                        SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Inspektor: Admin Rendy', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            Text('24 Okt, 08:30 WIB', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Dokumentasi Payet & Ornamen (4 Foto)', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      Text('Lihat Detail >', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildPhotoThumb('Payet Depan', 'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?auto=format&fit=crop&w=150&q=80'),
                      const SizedBox(width: 6),
                      _buildPhotoThumb('Omprok Mahkota', 'https://images.unsplash.com/photo-1578632767115-351597cf2477?auto=format&fit=crop&w=150&q=80'),
                      const SizedBox(width: 6),
                      _buildPhotoThumb('Kain Jarik', 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?auto=format&fit=crop&w=150&q=80'),
                      const SizedBox(width: 6),
                      _buildPhotoThumb('Kipas 12 Pcs', 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?auto=format&fit=crop&w=150&q=80'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.accentGreenBg, borderRadius: BorderRadius.circular(10)),
                    child: const Row(
                      children: [
                        Icon(Icons.draw_rounded, color: AppColors.accentGreen, size: 18),
                        SizedBox(width: 8),
                        Text('Tanda Tangan Digital Penyewa: ', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        Text('Ni Made Sukmawati • 24 Okt 08:35 WIB', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accentGreen)),
                        Spacer(),
                        Icon(Icons.check_circle, size: 16, color: AppColors.accentGreen),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Rincian Pembayaran Card
            _buildSectionCard(
              title: 'Rincian Pembayaran',
              subtitle: 'Status transaksi otomatis',
              icon: Icons.payments_outlined,
              badge: const AppBadge(label: 'LUNAS', type: BadgeType.success),
              child: Column(
                children: [
                  _buildPriceRow('Biaya Sewa (12 stel × Rp 200.000)', 'Rp 2.400.000'),
                  const SizedBox(height: 4),
                  _buildPriceRow('Uang Jaminan / Deposit', 'Rp 500.000'),
                  const Divider(height: 20, color: AppColors.cardBorder),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total Ditransfer & Diterima', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                            Text('Metode: BCA Transfer Otomatis', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accentGreen)),
                          ],
                        ),
                        Text('Rp 2.900.000', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary)),
                      ],
                    ),
                  ),
                ],
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

  Widget _buildPhotoThumb(String label, String url) {
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

  Widget _buildPriceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ],
    );
  }
}
