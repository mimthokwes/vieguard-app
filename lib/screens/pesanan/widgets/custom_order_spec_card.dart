import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/order_model.dart';
import '../../../widgets/vg/vg_ui.dart';

class CustomOrderSpecCard extends StatelessWidget {
  final Order order;
  const CustomOrderSpecCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final d = order.customOrderDetail;
    final institution = order.customInstitution ?? '-';

    // Format Kategori & Jenjang
    final jenjang = d?.jenisJenjang;
    final itemName = order.items.isNotEmpty ? order.items.first.name : 'Kostum Custom';
    final categoryAndJenjang = jenjang != null && jenjang.isNotEmpty
        ? (itemName.contains(jenjang) ? itemName : '$itemName ($jenjang)')
        : itemName;

    // Deskripsi Desain & Bahan
    final designDescription = order.cleanDesignDescription ?? d?.designDescription ?? '-';
    final material = order.customMaterial ?? 'Standar Bahan Penjahit';
    final accessories = order.customAccessories ?? '-';

    return VgCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const VgCardTitle(
          title: 'Spesifikasi Permintaan',
          subtitle: 'Rincian Jahitan & Bahan',
          trailing: VgIconBadge(icon: Icons.handyman_outlined, color: Colors.white, background: AppColors.primary, size: 34),
        ),

        // 1. Nama Sekolah / Tim
        _SpecBlock(
          label: 'Nama Sekolah / Tim',
          value: institution,
        ),

        // 2. Baris Sejajar: Kategori & Jenjang (~70%) + Jumlah Kebutuhan (~30%)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 7,
                child: VgInset(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Kategori & Jenjang', style: TextStyle(fontSize: 12, color: AppColors.primary)),
                      const SizedBox(height: 3),
                      Text(
                        categoryAndJenjang,
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: VgInset(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Jumlah', style: TextStyle(fontSize: 12, color: AppColors.primary)),
                      const SizedBox(height: 3),
                      Text(
                        '${order.totalQuantity} Stel',
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // 3. Deskripsi Desain & Model
        _SpecBlock(
          label: 'Deskripsi Desain & Model',
          value: designDescription,
        ),

        // 4. Pilihan Bahan
        _SpecBlock(
          label: 'Pilihan Bahan',
          value: material,
        ),

        // 5. Aksesoris Tambahan (Menggantikan catatan konsultasi mentah)
        _SpecBlock(
          label: 'Aksesoris Tambahan',
          value: accessories,
        ),

        // Catatan Khusus Pelanggan jika ada
        if (order.notes != null && order.notes!.isNotEmpty)
          VgInset(
            color: AppColors.beigeSoft,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [
                Icon(Icons.sticky_note_2_outlined, size: 16, color: AppColors.primary),
                SizedBox(width: 6),
                Text('Catatan Khusus Pelanggan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
              ]),
              const SizedBox(height: 4),
              Text(
                '"${order.notes!}"',
                style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: AppColors.textPrimary, height: 1.4),
              ),
            ]),
          ),
      ]),
    );
  }
}

class _SpecBlock extends StatelessWidget {
  final String label;
  final String value;
  final String? trailingNote;
  const _SpecBlock({required this.label, required this.value, this.trailingNote});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: VgInset(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.primary)),
          const SizedBox(height: 3),
          Text.rich(
            TextSpan(children: [
              TextSpan(text: value, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              if (trailingNote != null)
                TextSpan(text: ' $trailingNote', style: const TextStyle(color: AppColors.primary, fontSize: 12.5)),
            ]),
            style: const TextStyle(fontSize: 13.5, height: 1.4),
          ),
        ]),
      ),
    );
  }
}
