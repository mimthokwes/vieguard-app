import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/providers/order_provider.dart';
import '../../../../core/models/order_model.dart';
import 'order_detail_standard_screen.dart';
import 'order_detail_custom_screen.dart';
import 'input_custom_price_screen.dart';
import 'production_progress_screen.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  final OrderProvider _orderProvider = OrderProvider();
  int _selectedFilterIndex = 0;

  @override
  void initState() {
    super.initState();
    _orderProvider.fetchOrders();
    _orderProvider.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final orders = _orderProvider.orders;
    final List<String> filters = [
      'Semua (${orders.length})',
      'Menunggu (${orders.where((o) => o.status == 'pending').length})',
      'Diproduksi (${orders.where((o) => o.status == 'diproses').length})',
    ];

    final pendingCount = orders.where((o) => o.status == 'pending').length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomHeaderAppBar(subtitle: 'Pesanan'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search & Filter Input Bar
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
                        hintText: 'Cari no. pesanan, nama sekolah/pemesan...',
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
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilterIndex = index;
                        });
                      },
                      selectedColor: AppColors.primary,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.cardBorder,
                        ),
                      ),
                      showCheckmark: false,
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 14),

            // Verification Needed Alert Banner
            if (pendingCount > 0) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primaryBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.bolt_rounded, size: 16, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$pendingCount Pesanan Butuh Verifikasi',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                          const Text(
                            'Tenggat validasi produksi hari ini',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const OrderDetailStandardScreen()),
                        );
                      },
                      child: const Row(
                        children: [
                          Text(
                            'Tinjau',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                          Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primary),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Dynamic Cards from Backend
            if (_orderProvider.isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
            else if (orders.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: const Text('Belum ada pesanan tersimpan di backend.', style: TextStyle(color: AppColors.textMuted)),
              )
            else
              Column(
                children: List.generate(orders.length, (index) {
                  final OrderModel order = orders[index];

                  Color borderAccent = AppColors.accentBlue;
                  BadgeType statusType = BadgeType.info;
                  if (order.status == 'pending') {
                    borderAccent = AppColors.accentOrange;
                    statusType = BadgeType.warning;
                  } else if (order.status == 'selesai' || order.status == 'siap_diambil') {
                    borderAccent = AppColors.accentGreen;
                    statusType = BadgeType.success;
                  }

                  final itemName = order.items.isNotEmpty ? order.items.first.itemName : 'Seragam Paket';
                  final qty = order.items.isNotEmpty ? order.items.first.quantity : 1;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _buildOrderCard(
                      context,
                      borderAccentColor: borderAccent,
                      orderNo: order.orderNumber,
                      timeAgo: 'Terbaru',
                      statusLabel: order.statusLabel,
                      statusType: statusType,
                      schoolName: order.schoolOrInstitution,
                      packageName: itemName,
                      unitCount: '$qty Stel',
                      specDesc: 'Pelanggan: ${order.customerName} • Status: ${order.status}',
                      totalPrice: 'Rp ${order.totalPrice.toStringAsFixed(0)}',
                      dpStatus: order.isLunas ? 'Lunas Terverifikasi' : 'DP: Rp ${order.dpAmount.toStringAsFixed(0)}',
                      isLunas: order.isLunas,
                      actionButtons: [
                        Expanded(
                          child: AppButton(
                            text: 'Detail',
                            onPressed: () {
                              if (order.orderType == 'custom') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const OrderDetailCustomScreen()),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const OrderDetailStandardScreen()),
                                );
                              }
                            },
                            isPrimary: false,
                            isSecondary: true,
                            height: 40,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AppButton(
                            text: order.status == 'pending' ? 'Konfirmasi' : 'Progres',
                            onPressed: () {
                              if (order.status == 'pending') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const InputCustomPriceScreen()),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const ProductionProgressScreen()),
                                );
                              }
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

  Widget _buildOrderCard(
    BuildContext context, {
    required Color borderAccentColor,
    required String orderNo,
    required String timeAgo,
    required String statusLabel,
    required BadgeType statusType,
    required String schoolName,
    required String packageName,
    required String unitCount,
    required String specDesc,
    String? sizePillText,
    double? progressBarValue,
    String? progressLabel,
    String? progressPercentageText,
    required String totalPrice,
    String? dpStatus,
    bool isLunas = false,
    bool isEstimatedPrice = false,
    required List<Widget> actionButtons,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Colored Accent Line
              Container(width: 5, color: borderAccentColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(orderNo, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                              const SizedBox(width: 6),
                              const Text('•', style: TextStyle(color: AppColors.textMuted)),
                              const SizedBox(width: 6),
                              Text(timeAgo, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                            ],
                          ),
                          AppBadge(label: statusLabel, type: statusType),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(schoolName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      const SizedBox(height: 10),

                      // Package Box Container
                      Container(
                        width: double.infinity,
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
                              children: [
                                Expanded(
                                  child: Text(
                                    packageName,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(unitCount, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(specDesc, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),

                            if (sizePillText != null) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.accentGreenBorder),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.description, size: 12, color: AppColors.accentGreen),
                                    const SizedBox(width: 4),
                                    Text(sizePillText, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.accentGreen)),
                                  ],
                                ),
                              ),
                            ],

                            if (progressBarValue != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(progressLabel ?? '', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                  Text(progressPercentageText ?? '', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.accentBlue)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: progressBarValue,
                                  minHeight: 6,
                                  backgroundColor: Colors.white,
                                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentBlue),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Price & Action Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(isEstimatedPrice ? 'Estimasi Biaya' : 'Total Nilai', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                              Text(
                                totalPrice,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: isEstimatedPrice ? AppColors.textMuted : AppColors.textPrimary,
                                ),
                              ),
                              if (dpStatus != null) ...[
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    if (isLunas) const Icon(Icons.check_circle, size: 12, color: AppColors.accentGreen),
                                    if (isLunas) const SizedBox(width: 2),
                                    Text(
                                      dpStatus,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isLunas ? AppColors.accentGreen : AppColors.accentGreen,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Action Buttons
                      Row(children: actionButtons),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
