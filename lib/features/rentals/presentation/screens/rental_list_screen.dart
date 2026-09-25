import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/providers/rental_provider.dart';
import '../../../../core/models/rental_model.dart';
import 'rental_detail_screen.dart';
import 'item_condition_form_screen.dart';
import 'rental_calendar_screen.dart';
import 'rental_stock_management_screen.dart';

class RentalListScreen extends StatefulWidget {
  const RentalListScreen({super.key});

  @override
  State<RentalListScreen> createState() => _RentalListScreenState();
}

class _RentalListScreenState extends State<RentalListScreen> {
  final RentalProvider _rentalProvider = RentalProvider();
  int _selectedHeaderTab = 0;
  int _selectedFilterIndex = 0;

  @override
  void initState() {
    super.initState();
    _rentalProvider.fetchCalendar();
    _rentalProvider.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final rentals = _rentalProvider.rentals;
    final List<String> filters = [
      'Semua (${rentals.length})',
      'Aktif / Berjalan (${rentals.where((r) => r.status == 'diambil' || r.status == 'dipesan').length})',
      'Selesai (${rentals.where((r) => r.status == 'dikembalikan').length})',
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomHeaderAppBar(subtitle: 'Penyewaan Alat'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section Tabs: Daftar Sewa | Kalender | Stok
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildHeaderTabButton(
                      label: 'Daftar Sewa',
                      icon: Icons.view_list_rounded,
                      isSelected: _selectedHeaderTab == 0,
                      onTap: () => setState(() => _selectedHeaderTab = 0),
                    ),
                  ),
                  Expanded(
                    child: _buildHeaderTabButton(
                      label: 'Kalender',
                      icon: Icons.calendar_today_rounded,
                      isSelected: _selectedHeaderTab == 1,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RentalCalendarScreen()),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: _buildHeaderTabButton(
                      label: 'Stok',
                      icon: Icons.inventory_2_outlined,
                      isSelected: _selectedHeaderTab == 2,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RentalStockManagementScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Search & Filter Bar
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Cari no. sewa, penyewa, nama kostum...',
                        hintStyle: TextStyle(fontSize: 13, color: AppColors.textMuted),
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
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.tune_rounded, color: AppColors.textPrimary, size: 20),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Filter Chips Bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(filters.length, (index) {
                  final isSelected = _selectedFilterIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filters[index]),
                      selected: isSelected,
                      onSelected: (selected) => setState(() => _selectedFilterIndex = index),
                      selectedColor: AppColors.primary,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: isSelected ? AppColors.primary : AppColors.cardBorder),
                      ),
                      showCheckmark: false,
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 14),

            // Dynamic Cards from Rental Provider
            if (_rentalProvider.isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
            else if (rentals.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: const Text('Belum ada penyewaan tersimpan di backend.', style: TextStyle(color: AppColors.textMuted)),
              )
            else
              Column(
                children: List.generate(rentals.length, (index) {
                  final RentalModel rental = rentals[index];
                  BadgeType statusType = BadgeType.info;
                  if (rental.status == 'dipesan') {
                    statusType = BadgeType.warning;
                  } else if (rental.status == 'dikembalikan') {
                    statusType = BadgeType.success;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _buildRentalCard(
                      context,
                      rentalNo: '#RENT-${rental.id.length > 4 ? rental.id.substring(0, 4) : rental.id}',
                      tag: 'Penyewaan Kostum',
                      statusLabel: rental.status.toUpperCase(),
                      statusType: statusType,
                      tenantName: rental.customerName,
                      costumeTitle: rental.costumeTitle,
                      costumeDesc: 'Kondisi awal: ${rental.itemConditionBefore ?? "Baik"} • No Telp: ${rental.customerPhone}',
                      dateRange: '${rental.pickupDate} s/d ${rental.returnDate}',
                      totalPrice: 'Denda: Rp ${rental.penaltyAmount.toStringAsFixed(0)}',
                      depositInfo: 'Status: ${rental.status}',
                      actionButtons: [
                        Expanded(
                          child: AppButton(
                            text: 'Inspeksi',
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const ItemConditionFormScreen()));
                            },
                            isPrimary: false,
                            isSecondary: true,
                            height: 40,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AppButton(
                            text: 'Detail',
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const RentalDetailScreen()));
                            },
                            isPrimary: true,
                            height: 40,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderTabButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRentalCard(
    BuildContext context, {
    Color? borderAccentColor,
    required String rentalNo,
    required String tag,
    required String statusLabel,
    required BadgeType statusType,
    required String tenantName,
    required String costumeTitle,
    required String costumeDesc,
    required String dateRange,
    bool isUrgentDate = false,
    required String totalPrice,
    String? depositInfo,
    String? dpBadge,
    bool isLunasGreen = false,
    required List<Widget> actionButtons,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderAccentColor ?? AppColors.cardBorder, width: borderAccentColor != null ? 1.5 : 1.0),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(rentalNo, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
              const SizedBox(width: 6),
              const Text('•', style: TextStyle(color: AppColors.textMuted)),
              const SizedBox(width: 6),
              Text(tag, style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold)),
              const Spacer(),
              AppBadge(label: statusLabel, type: statusType),
            ],
          ),
          const SizedBox(height: 8),
          Text(tenantName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 10),

          // Item Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.checkroom_rounded, color: AppColors.primary, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(costumeTitle, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      Text(costumeDesc, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 12, color: isUrgentDate ? AppColors.accentOrange : AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            dateRange,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isUrgentDate ? AppColors.accentOrange : AppColors.primary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Price & Deposit Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Denda / Biaya', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                  Text(totalPrice, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                ],
              ),
              if (depositInfo != null)
                Text(depositInfo, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accentGreen)),
            ],
          ),
          const SizedBox(height: 12),

          // Action Buttons
          Row(children: actionButtons),
        ],
      ),
    );
  }
}
