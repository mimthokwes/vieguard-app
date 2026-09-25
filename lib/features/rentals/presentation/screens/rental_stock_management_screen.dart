import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import 'rental_stock_detail_screen.dart';

import '../../../../core/providers/product_provider.dart';

class RentalStockManagementScreen extends StatefulWidget {
  const RentalStockManagementScreen({super.key});

  @override
  State<RentalStockManagementScreen> createState() => _RentalStockManagementScreenState();
}

class _RentalStockManagementScreenState extends State<RentalStockManagementScreen> {
  final ProductProvider _productProvider = ProductProvider();
  int _selectedCategoryIndex = 0;
  final List<String> _categories = ['Semua Kategori', 'Adat Nusantara', 'Tari Tradisional'];

  @override
  void initState() {
    super.initState();
    _productProvider.fetchProducts();
    _productProvider.fetchCategories();
    _productProvider.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomHeaderAppBar(subtitle: 'Manajemen Stok'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PUSAT LOGISTIK KOSTUM', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted, letterSpacing: 0.5)),
                    Text('Manajemen Stok', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                  ],
                ),
                Row(
                  children: [
                    IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
                    Container(
                      decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                      child: IconButton(icon: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.primary), onPressed: () {}),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Summary Stat Cards (2x2 Grid)
            Row(
              children: [
                _buildStatCard('Total Koleksi', '185', 'Stel', '14 Kategori Utama', Icons.inventory_2_outlined, AppColors.primaryLight, AppColors.primary),
                const SizedBox(width: 10),
                _buildStatCard('Tersedia Gudang', '43', 'Stel', '23% Unit Ready', Icons.check_circle_outline, AppColors.accentGreenBg, AppColors.accentGreen),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildStatCard('Sedang Disewa', '134', 'Stel', '72% Okupansi Aktif', Icons.assignment_outlined, AppColors.primaryLight, AppColors.primary),
                const SizedBox(width: 10),
                _buildStatCard('Laundry / Servis', '8', 'Stel', 'Perawatan Berkala', Icons.wash_outlined, AppColors.accentOrangeBg, AppColors.accentOrange),
              ],
            ),
            const SizedBox(height: 16),

            // Search Bar & Filter Chips
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.cardBorder)),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Cari jenis kostum, kategori, kode SKU...',
                        hintStyle: TextStyle(fontSize: 12, color: AppColors.textMuted),
                        prefixIcon: Icon(Icons.search, color: AppColors.textMuted, size: 20),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.cardBorder)),
                  child: IconButton(icon: const Icon(Icons.tune_rounded, color: AppColors.textPrimary, size: 20), onPressed: () {}),
                ),
              ],
            ),
            const SizedBox(height: 12),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_categories.length, (index) {
                  final isSelected = _selectedCategoryIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_categories[index]),
                      selected: isSelected,
                      onSelected: (selected) => setState(() => _selectedCategoryIndex = index),
                      selectedColor: AppColors.primary,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textSecondary, fontSize: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? AppColors.primary : AppColors.cardBorder)),
                      showCheckmark: false,
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),

            // Stock Catalog List Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Katalog Kostum', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                Text('Urutkan: Stok ▾', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 12),

            // Item 1: Kostum Tari Gandrung
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.cardBorder)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: const DecorationImage(
                            image: NetworkImage('https://images.unsplash.com/photo-1578632767115-351597cf2477?auto=format&fit=crop&w=200&q=80'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('KST-TGD-01', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                AppBadge(label: '4 Ready', type: BadgeType.success),
                              ],
                            ),
                            const SizedBox(height: 2),
                            const Text('Kostum Tari Gandrung', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                            const Text('Kategori: Tari Tradisional', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            const SizedBox(height: 4),
                            const Text('Rp 200.000 / hari', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.primary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  const Text('Stok Tersedia: 4 dari 16 Stel', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: const LinearProgressIndicator(value: 0.25, minHeight: 6, backgroundColor: Color(0xFFE2E8F0), valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentGreen)),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      _buildSizePill('S (1)'),
                      const SizedBox(width: 4),
                      _buildSizePill('M (2)'),
                      const SizedBox(width: 4),
                      _buildSizePill('L (1)'),
                      const SizedBox(width: 4),
                      _buildSizePill('XL (0)', isOutOfStock: true),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    text: 'Lihat Rincian Stok & Riwayat',
                    icon: Icons.tune_outlined,
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const RentalStockDetailScreen()));
                    },
                    isPrimary: false,
                    isOutline: true,
                    height: 40,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Item 2: Drumband Cadet (Full Rented)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.cardBorder)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: const DecorationImage(
                            image: NetworkImage('https://images.unsplash.com/photo-1594938298603-c8148c4dae35?auto=format&fit=crop&w=200&q=80'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('KST-DRM-04', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                AppBadge(label: 'Penuh Disewa', type: BadgeType.danger),
                              ],
                            ),
                            const SizedBox(height: 2),
                            const Text('Drumband Cadet', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                            const Text('Kategori: Drumband & Karnaval', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            const SizedBox(height: 4),
                            const Text('Rp 225.000 / hari', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.primary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tersedia: 0 / Total: 28 Stel', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accentRed)),
                      Text('100% Terpakai', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: const LinearProgressIndicator(value: 1.0, minHeight: 6, backgroundColor: Color(0xFFE2E8F0), valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentRed)),
                  ),
                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.accentOrangeBg, borderRadius: BorderRadius.circular(10)),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_month, size: 14, color: AppColors.accentOrange),
                            SizedBox(width: 6),
                            Text('Estimasi Kembali Gudang:', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        ),
                        Text('28 Okt 2024', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  AppButton(
                    text: 'Ingatkan Pengembalian',
                    icon: Icons.notifications_active_outlined,
                    onPressed: () {},
                    isPrimary: false,
                    isSecondary: true,
                    height: 40,
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

  Widget _buildStatCard(String label, String value, String unit, String subtitle, IconData icon, Color bg, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.cardBorder)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                  child: Icon(icon, size: 16, color: color),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                const SizedBox(width: 4),
                Text(unit, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildSizePill(String label, {bool isOutOfStock = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isOutOfStock ? AppColors.accentRedBg : AppColors.primaryLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isOutOfStock ? AppColors.accentRed : AppColors.primary,
        ),
      ),
    );
  }
}
