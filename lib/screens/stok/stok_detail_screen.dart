import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/storage/image_cache_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/order_status.dart';
import '../../models/product_model.dart';
import '../../state/product_provider.dart';
import '../../state/rental_provider.dart';
import '../../widgets/common/tap_scale.dart';
import '../../widgets/common/vg_alert.dart';
import '../../widgets/vg/vg_form.dart';
import '../../widgets/vg/vg_ui.dart';
import '../penyewaan/penyewaan_detail_screen.dart';
import 'stock_adjust_screen.dart';

class StokDetailScreen extends StatefulWidget {
  final String productId;
  const StokDetailScreen({super.key, required this.productId});

  @override
  State<StokDetailScreen> createState() => _StokDetailScreenState();
}

class _StokDetailScreenState extends State<StokDetailScreen> {
  int _image = 0;
  bool _showAllHistory = false;

  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  String? _categoryId;
  String _conditionGrade = 'A';
  bool _isCustomAvailable = false;
  bool _initialized = false;
  bool _updating = false;
  bool _deleting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _initForm(Product product) {
    if (_initialized) return;
    _nameController.text = product.name;
    _skuController.text = product.sku ?? '';
    _descriptionController.text = product.description ?? '';
    if (product.isRentable) {
      _priceController.text = product.basePriceRent?.toStringAsFixed(0) ?? '';
    } else {
      _priceController.text = product.basePriceBuy?.toStringAsFixed(0) ?? '';
    }
    _categoryId = product.categoryId;
    _conditionGrade = product.conditionGrade ?? 'A';
    _isCustomAvailable = product.isCustomAvailable;
    _initialized = true;
  }

  void _zoom(String url) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(children: [
          InteractiveViewer(child: VgImage(url: url, fit: BoxFit.contain)),
          Positioned(right: 4, top: 4, child: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(ctx))),
        ]),
      ),
    );
  }

  Future<void> _saveProductChanges(Product product) async {
    if (_updating) return;
    final name = _nameController.text.trim();
    if (name.length < 2) {
      VgAlert.error(context: context, title: 'Validasi Gagal', message: 'Nama produk minimal 2 karakter.');
      return;
    }
    final rawPrice = _priceController.text.replaceAll('.', '').replaceAll(',', '').trim();
    final price = double.tryParse(rawPrice);
    if (price == null || price < 0) {
      VgAlert.error(context: context, title: 'Validasi Gagal', message: 'Harap masukkan nominal harga yang valid.');
      return;
    }

    setState(() => _updating = true);
    final provider = context.read<ProductProvider>();
    final payload = <String, dynamic>{
      'name': name,
      'categoryId': _categoryId ?? product.categoryId,
      'sku': _skuController.text.trim().toUpperCase(),
      'description': _descriptionController.text.trim(),
      'isCustomAvailable': _isCustomAvailable,
    };

    if (product.isRentable) {
      payload['basePriceRent'] = price;
      payload['conditionGrade'] = _conditionGrade;
    } else {
      payload['basePriceBuy'] = price;
    }

    final updated = await provider.updateProduct(product.id, payload);
    if (!mounted) return;
    setState(() => _updating = false);

    if (updated != null) {
      VgAlert.success(
        context: context,
        title: 'Berhasil Diperbarui',
        message: 'Informasi produk berhasil disimpan.',
      );
    } else {
      VgAlert.error(
        context: context,
        title: 'Gagal Memperbarui',
        message: provider.errorMessage ?? 'Gagal menyimpan perubahan produk.',
      );
    }
  }

  Future<void> _toggleVisibility(Product product) async {
    final provider = context.read<ProductProvider>();
    final targetStatus = !product.isVisible;
    final ok = await provider.toggleVisibility(product.id, targetStatus);
    if (!mounted) return;
    if (ok) {
      VgAlert.success(
        context: context,
        title: 'Visibilitas Diperbarui',
        message: targetStatus ? 'Produk sekarang ditampilkan di katalog.' : 'Produk telah disembunyikan dari katalog.',
      );
    } else {
      VgAlert.error(
        context: context,
        title: 'Gagal Memperbarui',
        message: provider.errorMessage ?? 'Gagal mengubah visibilitas produk.',
      );
    }
  }

  void _confirmDelete(Product product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Produk', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        content: Text('Apakah Anda yakin ingin menghapus "${product.name}"? Produk ini akan dinonaktifkan dari katalog.'),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(children: [
            Expanded(
              child: VgButton(
                label: 'Batal',
                style: VgButtonStyle.soft,
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () async {
                  Navigator.pop(ctx);
                  setState(() => _deleting = true);
                  final provider = context.read<ProductProvider>();
                  final ok = await provider.deleteProduct(product.id);
                  if (!mounted) return;
                  setState(() => _deleting = false);
                  if (ok) {
                    VgAlert.success(
                      context: context,
                      title: 'Produk Dihapus',
                      message: 'Produk "${product.name}" berhasil dihapus.',
                    );
                    Navigator.pop(context);
                  } else {
                    VgAlert.error(
                      context: context,
                      title: 'Gagal Menghapus',
                      message: provider.errorMessage ?? 'Terjadi kesalahan saat menghapus produk.',
                    );
                  }
                },
                child: const Text('Hapus', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final product = provider.productById(widget.productId);
    final rentals = context.watch<RentalProvider>();

    if (product == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        appBar: VgBackBar(title: 'Detail Stok Item'),
        body: Center(child: Text('Produk tidak ditemukan.')),
      );
    }

    _initForm(product);

    final history = rentals.rentalsForProduct(product.id);
    final year = DateTime.now().year;
    final revenue = history
        .where((o) => o.rental!.pickupDate.year == year && o.rental!.status != RentalStatus.dipesan)
        .expand((o) => o.items)
        .where((i) => i.productId == product.id)
        .fold<double>(0, (s, i) => s + i.subtotal);
    final images = product.imageUrls;
    final categories = provider.categories;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const VgBackBar(title: 'Detail Stok Item'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
        children: [
          // ── Foto Banner & Gallery ───────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 240,
              child: Stack(fit: StackFit.expand, children: [
                images.isEmpty
                    ? Container(color: AppColors.beige, child: const Icon(Icons.checkroom_rounded, size: 72, color: AppColors.primary))
                    : VgImage(url: images[_image], fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(color: AppColors.beige, child: const Icon(Icons.checkroom_rounded, size: 72, color: AppColors.primary))),
                const DecoratedBox(
                  decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0xCC3A0008)], stops: [0.45, 1])),
                ),
                Positioned(
                  left: 12,
                  top: 12,
                  child: VgPill(
                    label: product.isRentable
                        ? 'Barang Sewa · Grade ${product.conditionGrade ?? "A"}'
                        : 'Barang Pembelian (Pre-Order)',
                    color: product.isRentable ? AppColors.primary : AppColors.goldDark,
                    background: Colors.white,
                    dot: true,
                    fontSize: 11,
                  ),
                ),
                Positioned(
                  left: 14,
                  bottom: 14,
                  right: 60,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(product.sku != null && product.sku!.isNotEmpty ? 'SKU Inventaris' : 'Kategori', style: const TextStyle(fontSize: 11.5, color: Colors.white70)),
                    Text(product.sku != null && product.sku!.isNotEmpty ? '#${product.sku}' : product.categoryName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Colors.white)),
                  ]),
                ),
                if (images.isNotEmpty)
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: TapScale(
                      onTap: () => _zoom(images[_image]),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.25), shape: BoxShape.circle),
                        child: const Icon(Icons.zoom_in_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
              ]),
            ),
          ),
          if (images.length > 1) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, i) => TapScale(
                  onTap: () => setState(() => _image = i),
                  child: VgPill(
                    label: 'Foto ${i + 1}',
                    color: i == _image ? Colors.white : AppColors.primary,
                    background: i == _image ? AppColors.primary : AppColors.beige,
                    icon: Icons.photo_outlined,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),

          // ── Nama Produk (Ikon mata dihapus sesuai instruksi) ────────────────
          Text(
            product.name,
            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800, color: AppColors.textPrimary, height: 1.2),
          ),
          const SizedBox(height: 4),
          Text(
            [product.categoryName, if (product.description != null && product.description!.isNotEmpty) product.description!].join(' • '),
            style: const TextStyle(fontSize: 13.5, color: AppColors.primary, height: 1.35),
          ),
          const SizedBox(height: 16),

          // ── Form Edit Data Produk (Pengganti Ketersediaan Real-Time) ─────────
          VgCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              VgCardTitle(
                title: 'Update Informasi Produk',
                subtitle: 'Ubah nama, harga, deskripsi, dan kategori produk',
                trailing: VgPill(
                  label: product.isRentable ? 'Barang Sewa' : 'Barang Pembelian',
                  color: product.isRentable ? AppColors.primary : AppColors.goldDark,
                  background: product.isRentable ? AppColors.beige : AppColors.warningBg,
                ),
              ),
              const VgLabel('Nama Produk *'),
              VgTextField(
                controller: _nameController,
                hint: 'Contoh: Kostum Mayoret Sapphire Royal',
              ),
              const SizedBox(height: 12),

              const VgLabel('Kategori Produk'),
              categories.isEmpty
                  ? const Text('Belum ada kategori.', style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary))
                  : VgChoiceChips<String>(
                      options: [for (final c in categories) (c.id, c.name)],
                      selected: _categoryId,
                      onSelected: (v) => setState(() => _categoryId = v),
                    ),
              const SizedBox(height: 12),

              VgLabel(product.isRentable ? 'Harga Sewa / Hari *' : 'Harga Beli (Pre-Order) *'),
              VgTextField(
                controller: _priceController,
                prefix: 'Rp',
                suffix: product.isRentable ? '/ hari' : null,
                strong: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                hint: product.isRentable ? '50000' : '150000',
              ),
              const SizedBox(height: 12),

              const VgLabel('Kode SKU (opsional)'),
              VgTextField(
                controller: _skuController,
                hint: 'Contoh: MYR-001',
              ),
              const SizedBox(height: 12),

              if (product.isRentable) ...[
                const VgLabel('Kondisi Fisik Kostum'),
                Row(children: [
                  for (final g in [
                    ('A', 'Grade A (Sangat Terawat)'),
                    ('B', 'Grade B (Baik)'),
                    ('C', 'Grade C (Perlu Servis)'),
                  ])
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: TapScale(
                          onTap: () => setState(() => _conditionGrade = g.$1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _conditionGrade == g.$1 ? AppColors.primary : AppColors.surface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: _conditionGrade == g.$1 ? AppColors.primary : AppColors.border),
                            ),
                            child: Text(
                              g.$1,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _conditionGrade == g.$1 ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ]),
                const SizedBox(height: 12),
              ],

              const VgLabel('Deskripsi Produk (opsional)'),
              VgTextField(
                controller: _descriptionController,
                maxLines: 3,
                hint: 'Keterangan bahan, detail kelengkapan, dll.',
              ),
              const SizedBox(height: 16),

              VgButton(
                label: 'Simpan Perubahan Produk',
                icon: Icons.save_outlined,
                expanded: true,
                height: 48,
                loading: _updating,
                onPressed: () => _saveProductChanges(product),
              ),
            ]),
          ),
          const SizedBox(height: 14),

          // ── Aksesoris (khusus rental jika ada) ────────────────────────────────
          if (product.accessories.isNotEmpty)
            VgCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                VgCardTitle(
                  title: 'Aset & Aksesoris Wajib',
                  subtitle: 'Dicek saat serah terima & pengembalian',
                  trailing: VgPill(label: '${product.accessories.length} Item', color: AppColors.primary, background: AppColors.beige),
                ),
                for (final a in product.accessories)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: VgInset(
                      child: Row(children: [
                        const Icon(Icons.workspace_premium_outlined, size: 20, color: AppColors.goldDark),
                        const SizedBox(width: 10),
                        Expanded(child: Text(a.name, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
                        Text('${a.quantityPerSet} / stel', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      ]),
                    ),
                  ),
              ]),
            ),

          // ── Riwayat Penyewaan & Omset (jika barang sewa) ──────────────────────
          if (product.isRentable)
            VgCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.history_rounded, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const Expanded(child: Text('Riwayat & Utilisasi Sewa', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
                  if (history.length > 3)
                    TapScale(
                      onTap: () => setState(() => _showAllHistory = !_showAllHistory),
                      child: Text(_showAllHistory ? 'Ringkas' : 'Lihat Semua', style: const TextStyle(fontSize: 12.5, color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ),
                ]),
                const SizedBox(height: 12),
                VgInset(
                  child: Row(children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.payments_outlined, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Total Omset Sewa Item Ini', style: TextStyle(fontSize: 12, color: AppColors.primary)),
                        FittedBox(fit: BoxFit.scaleDown, child: Text(Formatters.rupiah(revenue), style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.primary))),
                      ]),
                    ),
                    VgPill(label: 'Tahun $year', color: AppColors.textPrimary, background: AppColors.surface, fontSize: 11),
                  ]),
                ),
                const SizedBox(height: 10),
                if (history.isEmpty)
                  const Text('Belum ada riwayat penyewaan untuk item ini.', style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary))
                else
                  for (final o in (_showAllHistory ? history : history.take(3)))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TapScale(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PenyewaanDetailScreen(orderId: o.id))),
                        child: VgInset(
                          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Container(
                              margin: const EdgeInsets.only(top: 5),
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(color: o.rental!.status == RentalStatus.dikembalikan ? AppColors.success : AppColors.primary, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(o.customer.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                Text('#${o.orderNumber}', style: const TextStyle(fontSize: 12, color: AppColors.primary)),
                              ]),
                            ),
                            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                              Text(
                                '${o.items.where((i) => i.productId == product.id).fold<int>(0, (s, i) => s + i.quantity)} Stel',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                              ),
                              Text(
                                o.rental!.status == RentalStatus.dikembalikan ? 'Selesai ${Formatters.date(o.rental!.actualReturnDate ?? o.rental!.returnDate)}' : 'Kembali ${Formatters.date(o.rental!.returnDate)}',
                                style: TextStyle(fontSize: 11.5, color: o.rental!.status == RentalStatus.dikembalikan ? AppColors.success : AppColors.primary),
                              ),
                            ]),
                          ]),
                        ),
                      ),
                    ),
              ]),
            ),
        ],
      ),

      // ── Tombol Aksi di Bottom Bar ───────────────────────────────────────────
      bottomNavigationBar: VgBottomBar(children: [
        // 1. Tombol Update Status & Stok Unit (Tetap dipertahankan)
        VgButton(
          label: 'Update Status & Stok Unit',
          icon: Icons.edit_note_rounded,
          expanded: true,
          height: 48,
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StockAdjustScreen(productId: product.id))),
        ),
        const SizedBox(height: 8),

        // 2. Tombol Sembunyikan / Tampilkan di Katalog (Di atas tombol hapus)
        VgButton(
          label: product.isVisible ? 'Sembunyikan dari Katalog' : 'Tampilkan di Katalog',
          icon: product.isVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          style: VgButtonStyle.soft,
          expanded: true,
          height: 44,
          onPressed: () => _toggleVisibility(product),
        ),
        const SizedBox(height: 8),

        // 3. Tombol Hapus Produk
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.dangerBg,
            foregroundColor: AppColors.danger,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFFCA5A5)),
            ),
            minimumSize: const Size(double.infinity, 44),
          ),
          onPressed: _deleting ? null : () => _confirmDelete(product),
          child: _deleting
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.danger))
              : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.danger),
                  SizedBox(width: 8),
                  Text('Hapus Produk', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.danger)),
                ]),
        ),
        const SizedBox(height: 6),
      ]),
    );
  }
}
