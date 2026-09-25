import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import 'production_progress_screen.dart';

class InputCustomPriceScreen extends StatefulWidget {
  const InputCustomPriceScreen({super.key});

  @override
  State<InputCustomPriceScreen> createState() => _InputCustomPriceScreenState();
}

class _InputCustomPriceScreenState extends State<InputCustomPriceScreen> {
  final TextEditingController _bahanController = TextEditingController(text: '95000');
  final TextEditingController _jahitController = TextEditingController(text: '55000');
  final TextEditingController _aksesorisController = TextEditingController(text: '35000');
  final TextEditingController _marginController = TextEditingController(text: '25');
  final TextEditingController _shippingController = TextEditingController(text: '350000');
  final TextEditingController _notesController = TextEditingController(
    text: 'Harga sudah termasuk bordir 2 titik, scotlight 3M tahan cuci, garansi ukuran 14 hari, dan packing polybag individual terlabel nama siswa.',
  );

  int _selectedPaymentScheme = 0; // 0: DP 50%, 1: Full 100%

  @override
  Widget build(BuildContext context) {
    // Dynamic calculations
    final double bahan = double.tryParse(_bahanController.text) ?? 0;
    final double jahit = double.tryParse(_jahitController.text) ?? 0;
    final double aksesoris = double.tryParse(_aksesorisController.text) ?? 0;
    final double marginPct = double.tryParse(_marginController.text) ?? 0;
    final double shipping = double.tryParse(_shippingController.text) ?? 0;

    final double hppPerStel = bahan + jahit + aksesoris;
    final double marginAmount = hppPerStel * (marginPct / 100.0);
    final double hargaSatuanFinal = hppPerStel + marginAmount;
    final double subtotalProduksi = hargaSatuanFinal * 80;
    final double totalPenawaran = subtotalProduksi + shipping;
    final double dpAmount = totalPenawaran / 2;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kalkulasi Proforma'),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary Header Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.checkroom, color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Row(
                          children: [
                            Text('#VG-2024-0895', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                            Spacer(),
                            AppBadge(label: 'B2B Institusi', type: BadgeType.warning),
                          ],
                        ),
                        SizedBox(height: 2),
                        Text('SMK Negeri 4 Bandung', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                        Text('Wearpack Custom Jurusan Mekatronika (80x)', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Komponen Biaya Pokok (HPP) Card
            _buildSectionCard(
              title: 'Komponen Biaya Pokok (HPP)',
              subtitle: 'Estimasi basis per stel (Total 80 stel)',
              icon: Icons.calculate_outlined,
              badge: const AppBadge(label: 'Tier VIP', type: BadgeType.purple),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputRow('1. Bahan Baku Kain American Drill (per stel)', _bahanController),
                  const SizedBox(height: 10),
                  _buildInputRow('2. Ongkos Jahit & Finishing Presisi (per stel)', _jahitController),
                  const SizedBox(height: 10),
                  _buildInputRow('3. Aksesoris, 3M & Bordir Komputer (per stel)', _aksesorisController),
                  const SizedBox(height: 10),

                  // Target Margin Input
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          '4. Target Margin Profit Admin',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.accentGreenBg, borderRadius: BorderRadius.circular(6)),
                        child: Text(
                          '+Rp ${marginAmount.toStringAsFixed(0)} / stel',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accentGreen),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _marginController,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text('%', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Calculation Output Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('HPP Dasar per Stel', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            Text('Rp ${hppPerStel.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Harga Satuan Final (+Margin)', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold)),
                            Text('Rp ${hargaSatuanFinal.toStringAsFixed(0)} / stel', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.primary)),
                          ],
                        ),
                        const Divider(height: 16, color: AppColors.primaryBorder),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subtotal Produksi (80 Stel)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            Text('Rp ${subtotalProduksi.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Pengiriman & Skema Pembayaran Card
            _buildSectionCard(
              title: 'Pengiriman & Skema Pembayaran',
              subtitle: 'Biaya logistik palet kargo & syarat termin',
              icon: Icons.local_shipping_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Biaya Pengiriman (Cargo Palet Aman)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _shippingController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      prefixText: 'Rp ',
                      suffixText: 'JNE Trucking / Kargo',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                    child: const Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
                        SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Estimasi Durasi Pengerjaan', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                            Text('21 Hari Kerja (Target Siap Kirim: 20 Nov 2024)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text('Pilihan Skema Pembayaran Institusi', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedPaymentScheme = 0),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _selectedPaymentScheme == 0 ? AppColors.primaryLight : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _selectedPaymentScheme == 0 ? AppColors.primary : AppColors.cardBorder, width: 1.5),
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Termin DP 50%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                SizedBox(height: 2),
                                Text('50% DP / 50% Pelunasan', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedPaymentScheme = 1),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _selectedPaymentScheme == 1 ? AppColors.primaryLight : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _selectedPaymentScheme == 1 ? AppColors.primary : AppColors.cardBorder, width: 1.5),
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Bayar Penuh 100%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                SizedBox(height: 2),
                                Text('Prioritas Antrean Ekstra', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // TOTAL PENAWARAN RESMI Card
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('TOTAL PENAWARAN RESMI', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 0.8)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(6)),
                        child: const Text('Final Netto', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Rp ${totalPenawaran.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                  const Divider(height: 20, color: Colors.white24),
                  Row(
                    children: [
                      const Icon(Icons.lens, size: 8, color: AppColors.accentOrange),
                      const SizedBox(width: 6),
                      const Text('Termin DP 50% (Mulai Produksi)', style: TextStyle(fontSize: 11, color: Colors.white)),
                      const Spacer(),
                      Text('Rp ${dpAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.lens, size: 8, color: AppColors.accentGreen),
                      const SizedBox(width: 6),
                      const Text('Pelunasan 50% (Sebelum Kirim)', style: TextStyle(fontSize: 11, color: Colors.white)),
                      const Spacer(),
                      Text('Rp ${dpAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Catatan Resmi untuk Pelanggan Text Area
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
                      const Row(
                        children: [
                          Icon(Icons.description_outlined, size: 16, color: AppColors.textMuted),
                          SizedBox(width: 6),
                          Text('Catatan Resmi untuk Pelanggan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        ],
                      ),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0)),
                        child: const Text('Template Standar', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
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
            const SizedBox(height: 20),

            // Submit Buttons
            AppButton(
              text: 'Kirim Penawaran ke Pelanggan',
              icon: Icons.send_rounded,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Penawaran harga resmi berhasil dikirim ke WhatsApp pemesan!')),
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProductionProgressScreen()),
                );
              },
              isPrimary: true,
              height: 50,
            ),
            const SizedBox(height: 10),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Draf penawaran berhasil disimpan.')),
                  );
                },
                icon: const Icon(Icons.bookmark_border_rounded, size: 16, color: AppColors.textSecondary),
                label: const Text(
                  'Simpan Draf Penawaran',
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

  Widget _buildInputRow(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            prefixText: 'Rp ',
            suffixText: '/ stel',
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }
}
