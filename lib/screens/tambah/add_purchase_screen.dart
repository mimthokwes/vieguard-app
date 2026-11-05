import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../state/product_provider.dart';
import '../../widgets/common/tap_scale.dart';
import '../../widgets/vg/vg_form.dart';
import '../../widgets/vg/vg_ui.dart';
import '../stok/stok_detail_screen.dart';

// ─── model helper ─────────────────────────────────────────────────────────────
class _VariantRow {
  final TextEditingController size;
  int stockBuy = 1;
  TextEditingController priceOverride = TextEditingController();
  _VariantRow(String s) : size = TextEditingController(text: s);
  void dispose() {
    size.dispose();
    priceOverride.dispose();
  }
}

// ─── screen ───────────────────────────────────────────────────────────────────
class AddPurchaseItemScreen extends StatefulWidget {
  const AddPurchaseItemScreen({super.key});

  @override
  State<AddPurchaseItemScreen> createState() => _AddPurchaseItemScreenState();
}

class _AddPurchaseItemScreenState extends State<AddPurchaseItemScreen> {
  static const _maxPhotos = 10;

  final _name = TextEditingController();
  final _sku = TextEditingController();
  final _description = TextEditingController();
  final _priceBuy = TextEditingController();

  final List<XFile> _photos = [];
  final List<_VariantRow> _variants = [
    _VariantRow('S'),
    _VariantRow('M'),
    _VariantRow('L'),
    _VariantRow('XL'),
  ];

  String? _categoryId;
  bool _visible = true;
  bool _custom = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final p = context.read<ProductProvider>();
      if (p.categories.isEmpty) p.fetchAll();
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _sku.dispose();
    _description.dispose();
    _priceBuy.dispose();
    for (final v in _variants) v.dispose();
    super.dispose();
  }

  double? _num(TextEditingController c) =>
      double.tryParse(c.text.replaceAll('.', '').replaceAll(',', '').trim());

  Future<void> _addPhotos() async {
    final picked = await pickPhotos(context);
    if (picked.isEmpty) return;
    setState(() => _photos.addAll(picked.take(_maxPhotos - _photos.length)));
  }

  Future<void> _addCategory() async {
    final products = context.read<ProductProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Kategori Baru'),
        content: VgTextField(controller: ctrl, hint: 'Contoh: Seragam Kantor'),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
        actions: [
          Row(children: [
            Expanded(child: VgButton(label: 'Batal', style: VgButtonStyle.soft, onPressed: () => Navigator.pop(ctx))),
            const SizedBox(width: 10),
            Expanded(child: VgButton(label: 'Simpan', onPressed: () => Navigator.pop(ctx, ctrl.text.trim()))),
          ]),
        ],
      ),
    );
    if (name == null || name.isEmpty || !mounted) return;
    final existing = products.categories.where((c) => c.name.toLowerCase() == name.toLowerCase());
    if (existing.isNotEmpty) {
      setState(() => _categoryId = existing.first.id);
      return;
    }
    final created = await products.createCategory(name);
    if (!mounted) return;
    if (created == null) {
      messenger.showSnackBar(SnackBar(content: Text(products.errorMessage ?? 'Gagal membuat kategori.')));
      return;
    }
    setState(() => _categoryId = created.id);
  }

  String? _validate() {
    if (_name.text.trim().length < 2) return 'Nama produk minimal 2 karakter.';
    if (_categoryId == null) return 'Pilih kategori produk.';
    if (_num(_priceBuy) == null) return 'Isi harga jual produk.';
    final sizes = _variants
        .map((v) => v.size.text.trim().toUpperCase())
        .where((s) => s.isNotEmpty)
        .toList();
    if (sizes.isEmpty) return 'Tambahkan minimal satu ukuran.';
    if (sizes.toSet().length != sizes.length) return 'Ada ukuran yang sama lebih dari sekali.';
    return null;
  }

  Future<void> _save() async {
    final problem = _validate();
    final messenger = ScaffoldMessenger.of(context);
    if (problem != null) {
      messenger.showSnackBar(SnackBar(content: Text(problem)));
      return;
    }
    setState(() => _saving = true);
    final provider = context.read<ProductProvider>();
    final created = await provider.createProduct({
      'categoryId': _categoryId,
      'name': _name.text.trim(),
      if (_description.text.trim().isNotEmpty) 'description': _description.text.trim(),
      'basePriceBuy': _num(_priceBuy),
      // stockRent = 0 karena ini barang beli
      'basePriceRent': null,
      'isVisible': _visible,
      'isCustomAvailable': _custom,
      if (_sku.text.trim().isNotEmpty) 'sku': _sku.text.trim().toUpperCase(),
      'variants': [
        for (final v in _variants)
          if (v.size.text.trim().isNotEmpty)
            {
              'size': v.size.text.trim().toUpperCase(),
              'stockBuy': v.stockBuy,
              'stockRent': 0, // Tidak disewakan
              if (_num(v.priceOverride) != null) 'priceBuyOverride': _num(v.priceOverride),
            },
      ],
    }, _photos);

    if (!mounted) return;
    setState(() => _saving = false);

    if (created == null) {
      messenger.showSnackBar(SnackBar(content: Text(provider.errorMessage ?? 'Gagal menyimpan produk.')));
      return;
    }
    messenger.showSnackBar(const SnackBar(content: Text('Produk beli berhasil ditambahkan.')));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => StokDetailScreen(productId: created.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<ProductProvider>().categories;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const VgBackBar(title: 'Tambah Barang Pembelian'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          // ── Info Banner ──────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.infoBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
            ),
            child: Row(children: [
              const Icon(Icons.shopping_bag_outlined, color: AppColors.info, size: 22),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Halaman ini untuk menambah barang yang akan dijual/dibeli pelanggan. Stok sewa tidak diisi.',
                  style: TextStyle(fontSize: 12.5, color: AppColors.info, height: 1.4),
                ),
              ),
            ]),
          ),

          // ── Foto ────────────────────────────────────────────────────────────
          VgCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              VgCardTitle(
                title: 'Foto Produk',
                subtitle: 'Maks. $_maxPhotos foto • foto pertama jadi sampul',
                trailing: VgPill(label: '${_photos.length}/$_maxPhotos', color: AppColors.primary, background: AppColors.beige),
              ),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: [
                  for (var i = 0; i < _photos.length; i++)
                    VgPhotoTile(file: _photos[i], caption: i == 0 ? 'Sampul' : null, onRemove: () => setState(() => _photos.removeAt(i))),
                  if (_photos.length < _maxPhotos) VgAddPhotoTile(onTap: _addPhotos),
                ],
              ),
            ]),
          ),

          // ── Informasi Dasar ──────────────────────────────────────────────────
          VgCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const VgCardTitle(
                title: 'Informasi Produk',
                subtitle: 'Data yang tampil di katalog pembelian',
                trailing: VgIconBadge(icon: Icons.shopping_bag_outlined, size: 38),
              ),
              const VgLabel('Nama Produk'),
              VgTextField(controller: _name, hint: 'Contoh: Seragam Batik Kantor Lengan Panjang'),
              const SizedBox(height: 12),
              const VgLabel('Kode SKU (opsional)'),
              VgTextField(controller: _sku, icon: Icons.qr_code_2_rounded, hint: 'SRG-BTK-01'),
              const SizedBox(height: 12),
              VgLabel(
                'Kategori',
                trailing: TapScale(
                  onTap: _addCategory,
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.add_rounded, size: 16, color: AppColors.primary),
                    Text('Kategori Baru', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  ]),
                ),
              ),
              categories.isEmpty
                  ? const Text('Belum ada kategori, buat kategori baru.', style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary))
                  : VgChoiceChips<String>(
                      options: [for (final c in categories) (c.id, c.name)],
                      selected: _categoryId,
                      onSelected: (v) => setState(() => _categoryId = v),
                    ),
              const SizedBox(height: 12),
              const VgLabel('Deskripsi (opsional)'),
              VgTextField(controller: _description, maxLines: 3, hint: 'Bahan, detail, keterangan tambahan…'),
            ]),
          ),

          // ── Harga Jual ───────────────────────────────────────────────────────
          VgCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const VgCardTitle(
                title: 'Harga Jual',
                subtitle: 'Harga dasar untuk pembelian',
                trailing: VgIconBadge(icon: Icons.sell_outlined, color: AppColors.goldDark, background: AppColors.warningBg, size: 38),
              ),
              const VgLabel('Harga Jual'),
              VgTextField(
                controller: _priceBuy,
                prefix: 'Rp',
                strong: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                hint: '150000',
              ),
            ]),
          ),

          // ── Varian & Stok ────────────────────────────────────────────────────
          VgCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              VgCardTitle(
                title: 'Ukuran & Stok Beli',
                subtitle: 'Jumlah unit fisik siap jual di gudang',
                trailing: VgPill(label: '${_variants.length} Ukuran', color: AppColors.primary, background: AppColors.beige),
              ),
              for (var i = 0; i < _variants.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: VgInset(
                    child: Column(children: [
                      Row(children: [
                        SizedBox(
                          width: 90,
                          child: VgTextField(
                            controller: _variants[i].size,
                            hint: 'Ukuran',
                            color: AppColors.surface,
                            strong: true,
                          ),
                        ),
                        const Spacer(),
                        TapScale(
                          onTap: _variants.length > 1
                              ? () => setState(() => _variants.removeAt(i).dispose())
                              : null,
                          child: Icon(
                            Icons.delete_outline_rounded,
                            color: _variants.length > 1 ? AppColors.danger : AppColors.border,
                          ),
                        ),
                      ]),
                      const SizedBox(height: 10),
                      Row(children: [
                        const Expanded(child: Text('Stok tersedia', style: TextStyle(fontSize: 12.5, color: AppColors.primary))),
                        VgStepper(value: _variants[i].stockBuy, onChanged: (v) => setState(() => _variants[i].stockBuy = v)),
                      ]),
                      const SizedBox(height: 8),
                      const VgLabel('Harga per ukuran (opsional, timpa harga dasar)'),
                      VgTextField(
                        controller: _variants[i].priceOverride,
                        prefix: 'Rp',
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        hint: 'Kosongkan jika sama dengan harga dasar',
                      ),
                    ]),
                  ),
                ),
              VgButton(
                label: 'Tambah Ukuran',
                icon: Icons.add_rounded,
                style: VgButtonStyle.soft,
                expanded: true,
                height: 42,
                onPressed: () => setState(() => _variants.add(_VariantRow(''))),
              ),
            ]),
          ),

          // ── Pengaturan ───────────────────────────────────────────────────────
          VgCard(
            child: Column(children: [
              VgSwitchRow(
                title: 'Tampil di Katalog',
                subtitle: 'Pelanggan bisa melihat & memesan',
                value: _visible,
                onChanged: (v) => setState(() => _visible = v),
              ),
              const Divider(height: 20),
              VgSwitchRow(
                title: 'Bisa Pesan Custom',
                subtitle: 'Tersedia di formulir pesanan custom',
                value: _custom,
                onChanged: (v) => setState(() => _custom = v),
              ),
            ]),
          ),
        ],
      ),
      bottomNavigationBar: VgBottomBar(children: [
        VgButton(
          label: 'Simpan Barang Beli',
          icon: Icons.save_outlined,
          expanded: true,
          height: 52,
          loading: _saving,
          onPressed: _save,
        ),
        const SizedBox(height: 6),
      ]),
    );
  }
}
