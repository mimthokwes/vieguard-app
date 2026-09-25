import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/api/auth_session.dart';
import '../../../orders/presentation/screens/order_detail_standard_screen.dart';
import '../../../orders/presentation/screens/order_detail_custom_screen.dart';
import '../../../rentals/presentation/screens/rental_list_screen.dart';
import '../../../rentals/presentation/screens/rental_stock_management_screen.dart';
import '../../../rentals/presentation/screens/rental_calendar_screen.dart';

import '../../../../core/providers/report_provider.dart';
import '../../../../core/providers/order_provider.dart';
import '../../../../core/providers/rental_provider.dart';
import '../../../../core/models/order_model.dart';
import '../../../../core/models/rental_model.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const HomeScreen({super.key, this.onNavigateToTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ReportProvider _reportProvider = ReportProvider();
  final OrderProvider _orderProvider = OrderProvider();
  final RentalProvider _rentalProvider = RentalProvider();

  @override
  void initState() {
    super.initState();
    _reportProvider.fetchSummary();
    _orderProvider.fetchOrders();
    _rentalProvider.fetchCalendar();
    _reportProvider.addListener(() {
      if (mounted) setState(() {});
    });
    _orderProvider.addListener(() {
      if (mounted) setState(() {});
    });
    _rentalProvider.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminName = AuthSession.currentAdmin?.name ?? 'Admin Operasional';
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomHeaderAppBar(subtitle: 'Beranda'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          dateStr,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Selamat Datang, $adminName',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Pantau konveksi seragam & rental kostum hari ini.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Ringkasan Hari Ini Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ringkasan Hari Ini',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Row(
                  children: const [
                    CircleAvatar(radius: 4, backgroundColor: AppColors.accentGreen),
                    SizedBox(width: 6),
                    Text(
                      'Live Backend Data',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Summary Stat Cards Row
            Row(
              children: [
                // Left Stat Card: Pesanan Baru
                Expanded(
                  child: Container(
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
                            const Text(
                              'Pesanan\nBaru',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppColors.primaryLight,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.assignment, size: 18, color: AppColors.primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${_reportProvider.summary?.totalOrders ?? _orderProvider.orders.length}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Pesanan di backend',
                          style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Right Stat Card: Kostum Disewa & Omset
                Expanded(
                  flex: 1,
                  child: Container(
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Kostum Disewa',
                                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                                Text(
                                  '${_reportProvider.summary?.activeRentals ?? _rentalProvider.rentals.length}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF3E8FF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.checkroom, size: 16, color: Color(0xFF7E22CE)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Progres Produksi Active',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: const LinearProgressIndicator(
                            value: 0.85,
                            minHeight: 6,
                            backgroundColor: Color(0xFFE2E8F0),
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Omset Total', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                Text(
                                  _reportProvider.summary != null
                                      ? 'Rp ${(_reportProvider.summary!.totalRevenue / 1000000).toStringAsFixed(1)}jt'
                                      : 'Rp 0',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.accentGreenBg,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.trending_up, size: 12, color: AppColors.accentGreen),
                                  SizedBox(width: 2),
                                  Text('Real', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.accentGreen)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Kelola Barang Horizontal Action Cards
            const Text(
              'Kelola Barang',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 110,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildQuickActionCard(
                    context,
                    title: 'Katalog Kostum',
                    subtitle: 'Kelola Stok',
                    icon: Icons.checkroom_rounded,
                    color: AppColors.primaryLight,
                    iconColor: AppColors.primary,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RentalStockManagementScreen()),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  _buildQuickActionCard(
                    context,
                    title: 'Jadwal Fitting',
                    subtitle: '${_rentalProvider.rentals.length} Aktif',
                    icon: Icons.calendar_month,
                    color: const Color(0xFFF3E8FF),
                    iconColor: const Color(0xFF7E22CE),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RentalCalendarScreen()),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  _buildQuickActionCard(
                    context,
                    title: 'Tambah Pesanan',
                    subtitle: 'Baru / Custom',
                    icon: Icons.add_circle_outline,
                    color: AppColors.primary,
                    iconColor: Colors.white,
                    textColor: Colors.white,
                    subtitleColor: Colors.white70,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const OrderDetailCustomScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Jadwal Rental Hari Ini Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'Jadwal Rental Hari Ini',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    if (widget.onNavigateToTab != null) {
                      widget.onNavigateToTab!(2);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RentalListScreen()),
                      );
                    }
                  },
                  child: const Row(
                    children: [
                      Text(
                        'Lihat Semua',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primary),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (_rentalProvider.isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
            else if (_rentalProvider.rentals.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: const Text('Belum ada jadwal rental tercatat di backend.', style: TextStyle(color: AppColors.textMuted)),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: List.generate(_rentalProvider.rentals.length, (index) {
                    final RentalModel rental = _rentalProvider.rentals[index];
                    final isLast = index == _rentalProvider.rentals.length - 1;
                    return Column(
                      children: [
                        _buildScheduleRow(
                          time: rental.pickupDate.isNotEmpty ? rental.pickupDate : '10:00 WIB',
                          title: rental.customerName,
                          subtitle: '${rental.costumeTitle} • Telp: ${rental.customerPhone}',
                          badgeLabel: rental.status.toUpperCase(),
                          badgeType: rental.status == 'dipesan'
                              ? BadgeType.info
                              : (rental.status == 'diambil' ? BadgeType.warning : BadgeType.success),
                        ),
                        if (!isLast) const Divider(height: 16, color: AppColors.cardBorder),
                      ],
                    );
                  }),
                ),
              ),
            const SizedBox(height: 24),

            // Pesanan Terbaru Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      'Pesanan Terbaru',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accentOrangeBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_orderProvider.orders.length} Pesanan',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.accentOrange),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    if (widget.onNavigateToTab != null) {
                      widget.onNavigateToTab!(1);
                    }
                  },
                  child: const Row(
                    children: [
                      Text(
                        'Semua',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primary),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (_orderProvider.isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
            else if (_orderProvider.orders.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: const Text('Belum ada pesanan masuk dari backend.', style: TextStyle(color: AppColors.textMuted)),
              )
            else
              Column(
                children: List.generate(_orderProvider.orders.length, (index) {
                  final OrderModel order = _orderProvider.orders[index];
                  final String itemName = order.items.isNotEmpty ? order.items.first.itemName : 'Seragam / Kostum';
                  final int itemQty = order.items.isNotEmpty ? order.items.first.quantity : 1;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildOrderCard(
                      context,
                      orderNo: order.orderNumber,
                      statusLabel: order.statusLabel,
                      statusType: order.status == 'pending'
                          ? BadgeType.warning
                          : (order.status == 'diproses' ? BadgeType.info : BadgeType.success),
                      title: order.schoolOrInstitution,
                      orderType: order.orderType == 'sewa' ? 'Penyewaan' : 'Pembelian',
                      desc: '$itemName ($itemQty Stel/Pcs)',
                      price: 'Rp ${order.totalPrice.toStringAsFixed(0)}',
                      imagePlaceholderColor: Colors.blue.shade100,
                      buttonText: 'Lihat Detail & Konfirmasi',
                      onButtonTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const OrderDetailStandardScreen()),
                        );
                      },
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

  Widget _buildQuickActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color iconColor,
    Color textColor = AppColors.textPrimary,
    Color subtitleColor = AppColors.textSecondary,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 10, color: subtitleColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleRow({
    required String time,
    required String title,
    required String subtitle,
    required String badgeLabel,
    required BadgeType badgeType,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            time,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
        ),
        AppBadge(label: badgeLabel, type: badgeType),
      ],
    );
  }

  Widget _buildOrderCard(
    BuildContext context, {
    required String orderNo,
    required String statusLabel,
    required BadgeType statusType,
    required String title,
    required String orderType,
    required String desc,
    required String price,
    required Color imagePlaceholderColor,
    required String buttonText,
    bool isSecondaryButton = false,
    required VoidCallback onButtonTap,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                orderNo,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted),
              ),
              AppBadge(label: statusLabel, type: statusType),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: imagePlaceholderColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.dry_cleaning_rounded, color: AppColors.primary, size: 30),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            orderType,
                            style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text(
                      price,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppButton(
            text: buttonText,
            onPressed: onButtonTap,
            isPrimary: !isSecondaryButton,
            isSecondary: isSecondaryButton,
            height: 40,
            icon: Icons.arrow_forward_rounded,
          ),
        ],
      ),
    );
  }
}
