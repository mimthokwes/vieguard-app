import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/order_status.dart';
import '../../models/report_summary_model.dart';
import '../../state/order_provider.dart';
import '../../state/product_provider.dart';
import '../../state/rental_provider.dart';
import '../../state/report_provider.dart';
import '../../widgets/common/date_range_picker_sheet.dart';
import '../../widgets/common/tap_scale.dart';
import '../../widgets/common/vg_skeleton.dart';
import '../../widgets/vg/vg_ui.dart';

enum _Period { bulanIni, bulanLalu, tigaBulan, tahunIni, custom }

enum _TypeFilter { semua, beli, sewa }

const _typeColors = {'beli': AppColors.primary, 'custom': Color(0xFFB0303F), 'sewa': Color(0xFFF59E0B)};

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  _Period _period = _Period.bulanIni;
  _TypeFilter _typeFilter = _TypeFilter.semua;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<ReportProvider>().fetchSummary();
      final orders = context.read<OrderProvider>();
      if (orders.orders.isEmpty) orders.fetchOrders();
      final rentals = context.read<RentalProvider>();
      if (rentals.rentalOrders.isEmpty) rentals.fetchRentals();
      final products = context.read<ProductProvider>();
      if (products.products.isEmpty) products.fetchAll();
    });
  }

  String _periodTriggerLabel(_Period p, ReportProvider r) => switch (p) {
        _Period.bulanIni => 'Bulan Ini (${DateFormat('MMM yyyy', 'id_ID').format(DateTime.now())})',
        _Period.bulanLalu => 'Bulan Lalu',
        _Period.tigaBulan => '3 Bulan Terakhir',
        _Period.tahunIni => 'Tahun Ini (${DateTime.now().year})',
        _Period.custom => '${Formatters.date(r.rangeStart)} - ${Formatters.date(r.rangeEnd)}',
      };

  Future<void> _selectPeriod(_Period p) async {
    final provider = context.read<ReportProvider>();
    final now = DateTime.now();
    switch (p) {
      case _Period.bulanIni:
        provider.setRange(DateTime(now.year, now.month, 1), now);
        break;
      case _Period.bulanLalu:
        provider.setRange(
          DateTime(now.year, now.month - 1, 1),
          DateTime(now.year, now.month, 0, 23, 59, 59),
        );
        break;
      case _Period.tigaBulan:
        provider.setRange(DateTime(now.year, now.month - 2, 1), now);
        break;
      case _Period.tahunIni:
        provider.setRange(DateTime(now.year, 1, 1), now);
        break;
      case _Period.custom:
        final range = await showCustomDateRangePicker(context, initialStart: provider.rangeStart, initialEnd: provider.rangeEnd);
        if (range == null) return;
        provider.setRange(range.start, DateTime(range.end.year, range.end.month, range.end.day, 23, 59, 59));
    }
    setState(() => _period = p);
  }

  PopupMenuItem<_Period> _buildMenuItem(_Period p, String label, IconData icon) {
    final isSelected = _period == p;
    return PopupMenuItem<_Period>(
      value: p,
      height: 42,
      child: Row(children: [
        Icon(icon, size: 17, color: isSelected ? AppColors.primary : AppColors.textSecondary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ),
        if (isSelected) const Icon(Icons.check_rounded, size: 18, color: AppColors.primary),
      ]),
    );
  }

  Widget _buildSegment({required _TypeFilter type, required String label, required IconData icon}) {
    final isSelected = _typeFilter == type;
    return Expanded(
      child: TapScale(
        onTap: () => setState(() => _typeFilter = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: isSelected ? AppColors.primary : AppColors.textSecondary),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _typeName(String type) => switch (type) {
        'beli' => 'Pembelian',
        'custom' => 'Pembelian Custom',
        'sewa' => 'Penyewaan',
        _ => type,
      };

  @override
  Widget build(BuildContext context) {
    final report = context.watch<ReportProvider>();
    final orders = context.watch<OrderProvider>().orders;
    final rentals = context.watch<RentalProvider>().rentalOrders;
    final products = context.watch<ProductProvider>().products;
    final summary = report.summary;
    final previous = report.previous;

    final inRange = orders
        .where((o) =>
            !o.createdAt.isBefore(report.rangeStart) &&
            !o.createdAt.isAfter(report.rangeEnd) &&
            o.status != OrderStatus.dibatalkan)
        .toList();

    final filteredOrders = switch (_typeFilter) {
      _TypeFilter.semua => inRange,
      _TypeFilter.beli => inRange.where((o) => o.orderType != OrderType.sewa).toList(),
      _TypeFilter.sewa => inRange.where((o) => o.orderType == OrderType.sewa).toList(),
    };

    final totalRevenue = switch (_typeFilter) {
      _TypeFilter.semua => summary?.totalRevenue ?? 0.0,
      _TypeFilter.beli => ((summary?.revenueByType['beli'] ?? 0) + (summary?.revenueByType['custom'] ?? 0)).toDouble(),
      _TypeFilter.sewa => (summary?.revenueByType['sewa'] ?? 0).toDouble(),
    };

    final prevRevenue = switch (_typeFilter) {
      _TypeFilter.semua => previous?.totalRevenue ?? 0.0,
      _TypeFilter.beli => ((previous?.revenueByType['beli'] ?? 0) + (previous?.revenueByType['custom'] ?? 0)).toDouble(),
      _TypeFilter.sewa => (previous?.revenueByType['sewa'] ?? 0).toDouble(),
    };
    final growth = prevRevenue == 0 ? null : (totalRevenue - prevRevenue) / prevRevenue * 100;

    final displayTotalOrders = _typeFilter == _TypeFilter.semua ? (summary?.totalOrders ?? 0) : filteredOrders.length;
    final displayCompletedOrders = _typeFilter == _TypeFilter.semua
        ? (summary?.completedOrders ?? 0)
        : filteredOrders.where((o) => o.status == OrderStatus.selesai).length;
    final displayPendingOrders = _typeFilter == _TypeFilter.semua
        ? (summary?.pendingOrders ?? 0)
        : filteredOrders.where((o) => o.status == OrderStatus.pending).length;

    final soldUnits = filteredOrders.fold<int>(0, (s, o) => s + o.totalQuantity);

    final totalStock = products.fold<int>(0, (s, p) => s + p.totalStockRent);
    final rentedNow = rentals
        .where((o) => o.rental!.status == RentalStatus.diambil || o.rental!.status == RentalStatus.terlambat)
        .fold<int>(0, (s, o) => s + o.totalQuantity);
    final utilization = totalStock == 0 ? 0.0 : (rentedNow / totalStock).clamp(0.0, 1.0);

    final returned = rentals.where((o) => o.rental!.status == RentalStatus.dikembalikan && o.rental!.actualReturnDate != null).toList();
    final onTime = returned.where((o) => !o.rental!.actualReturnDate!.isAfter(o.rental!.returnDate)).length;
    final onTimeRate = returned.isEmpty ? null : onTime / returned.length;

    final verifyDurations = filteredOrders
        .expand((o) => o.payments)
        .where((p) => p.status == PaymentStatus.terverifikasi && p.verifiedAt != null)
        .map((p) => p.verifiedAt!.difference(p.createdAt))
        .where((d) => !d.isNegative)
        .toList();
    final avgVerify = verifyDurations.isEmpty
        ? null
        : Duration(minutes: (verifyDurations.fold<int>(0, (s, d) => s + d.inMinutes) / verifyDurations.length).round());

    final best = <String, (double, int, String?)>{};
    for (final o in filteredOrders) {
      for (final i in o.items) {
        final prev = best[i.name];
        best[i.name] = (
          (prev?.$1 ?? 0) + i.subtotal,
          (prev?.$2 ?? 0) + i.quantity,
          prev?.$3 ?? i.imageUrl,
        );
      }
    }
    final topItems = best.entries.toList()..sort((a, b) => b.value.$1.compareTo(a.value.$1));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => report.fetchSummary(force: true),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              toolbarHeight: 68,
              backgroundColor: AppColors.background,
              surfaceTintColor: Colors.transparent,
              automaticallyImplyLeading: false,
              titleSpacing: 16,
              title: const VgTopBar(subtitle: 'Laporan & Analitik'),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 120),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  PopupMenuButton<_Period>(
                    color: AppColors.surface,
                    elevation: 6,
                    shadowColor: AppColors.primary.withValues(alpha: 0.15),
                    surfaceTintColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    onSelected: _selectPeriod,
                    itemBuilder: (_) => [
                      _buildMenuItem(_Period.bulanIni, 'Bulan Ini', Icons.calendar_today_rounded),
                      _buildMenuItem(_Period.bulanLalu, 'Bulan Lalu', Icons.history_rounded),
                      _buildMenuItem(_Period.tigaBulan, '3 Bulan', Icons.date_range_rounded),
                      _buildMenuItem(_Period.tahunIni, 'Tahun Ini', Icons.calendar_month_rounded),
                      const PopupMenuDivider(height: 10),
                      _buildMenuItem(_Period.custom, 'Pilih Rentang Tanggal', Icons.edit_calendar_rounded),
                    ],
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                        boxShadow: AppColors.cardShadow,
                      ),
                      child: Row(children: [
                        const Icon(Icons.calendar_month_outlined, size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _periodTriggerLabel(_period, report),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textPrimary, size: 20),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 42,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.beige,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(children: [
                      _buildSegment(type: _TypeFilter.semua, label: 'Semua', icon: Icons.grid_view_rounded),
                      _buildSegment(type: _TypeFilter.beli, label: 'Pembelian', icon: Icons.shopping_bag_outlined),
                      _buildSegment(type: _TypeFilter.sewa, label: 'Penyewaan', icon: Icons.assignment_outlined),
                    ]),
                  ),
                  const SizedBox(height: 14),
                  if (report.isLoading && summary == null) ...[
                    const VgSkeleton(width: double.infinity, height: 90, radius: 14),
                    const SizedBox(height: 12),
                    const VgSummaryMetricsSkeleton(),
                    const SizedBox(height: 14),
                    const VgSkeleton(width: double.infinity, height: 180, radius: 14),
                  ] else if (summary == null)
                    VgCard(child: Text(report.errorMessage ?? 'Belum ada data laporan.', style: const TextStyle(color: AppColors.textSecondary)))
                  else ...[
                    _CompletionBanner(totalOrders: displayTotalOrders, completedOrders: displayCompletedOrders),
                    const SizedBox(height: 12),
                    _KpiGrid(
                      filter: _typeFilter,
                      revenue: totalRevenue,
                      growth: growth,
                      totalOrders: displayTotalOrders,
                      completedOrders: displayCompletedOrders,
                      pendingOrders: displayPendingOrders,
                      orderDelta: previous == null ? null : (displayTotalOrders - (_typeFilter == _TypeFilter.semua ? previous.totalOrders : 0)),
                      utilization: utilization,
                      rentedNow: rentedNow,
                      totalStock: totalStock,
                      soldUnits: soldUnits,
                      totalCustomers: summary.totalCustomers,
                      sewaPct: summary.totalRevenue == 0 ? 0 : (((summary.revenueByType['sewa'] ?? 0) / summary.totalRevenue) * 100).round(),
                    ),
                    const SizedBox(height: 14),
                    if (_typeFilter == _TypeFilter.semua) ...[
                      _RevenueComposition(summary: summary, typeName: _typeName),
                    ],
                    VgCard(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(
                          switch (_typeFilter) {
                            _TypeFilter.semua => 'Katalog Terlaris',
                            _TypeFilter.beli => 'Produk Pembelian Terlaris',
                            _TypeFilter.sewa => 'Kostum Sewa Paling Diminati',
                          },
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          switch (_typeFilter) {
                            _TypeFilter.semua => 'Berdasarkan nilai pesanan pada periode ini',
                            _TypeFilter.beli => 'Berdasarkan volume pesanan beli pada periode ini',
                            _TypeFilter.sewa => 'Berdasarkan frekuensi sewa pada periode ini',
                          },
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 12),
                        if (topItems.isEmpty)
                          Text(
                            'Belum ada pesanan ${_typeFilter == _TypeFilter.beli ? 'pembelian' : _typeFilter == _TypeFilter.sewa ? 'penyewaan' : ''} pada periode ini.',
                            style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                          )
                        else
                          for (var i = 0; i < topItems.length && i < 3; i++)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: VgInset(
                                padding: const EdgeInsets.all(10),
                                child: Row(children: [
                                  VgThumb(url: topItems[i].value.$3, size: 46, radius: 8),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Text(topItems[i].key, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                      Text('${topItems[i].value.$2}x dipesan', style: const TextStyle(fontSize: 12, color: AppColors.primary)),
                                    ]),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                    Text(Formatters.rupiahCompact(topItems[i].value.$1), style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.primary)),
                                    if (i == 0) const Text('Top Revenue #1', style: TextStyle(fontSize: 11.5, color: AppColors.success)),
                                  ]),
                                ]),
                              ),
                            ),
                      ]),
                    ),
                    VgCard(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Row(children: [
                          Icon(Icons.speed_rounded, color: AppColors.primary, size: 20),
                          SizedBox(width: 8),
                          Expanded(child: Text('Efisiensi Operasional', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
                        ]),
                        const SizedBox(height: 12),
                        _Efficiency(
                          icon: Icons.task_alt_rounded,
                          label: _typeFilter == _TypeFilter.beli
                              ? 'Pesanan Beli Selesai'
                              : _typeFilter == _TypeFilter.sewa
                                  ? 'Pesanan Sewa Selesai'
                                  : 'Pesanan Selesai',
                          value: displayTotalOrders == 0 ? '-' : '${(displayCompletedOrders * 100 / displayTotalOrders).round()}% ($displayCompletedOrders/$displayTotalOrders)',
                          badge: displayPendingOrders > 0 ? '$displayPendingOrders Pending' : 'Tidak Ada Antrean',
                          good: displayPendingOrders == 0,
                        ),
                        _Efficiency(
                          icon: Icons.bolt_rounded,
                          label: 'Rata-rata Verifikasi Pembayaran',
                          value: avgVerify == null ? 'Belum ada data' : _duration(avgVerify),
                          badge: avgVerify == null ? '-' : (avgVerify.inHours < 24 ? 'Cepat' : 'Perlu Dipercepat'),
                          good: avgVerify != null && avgVerify.inHours < 24,
                        ),
                        if (_typeFilter != _TypeFilter.beli)
                          _Efficiency(
                            icon: Icons.history_rounded,
                            label: 'Pengembalian Sewa Tepat Waktu',
                            value: onTimeRate == null ? 'Belum ada data' : '${(onTimeRate * 100).toStringAsFixed(1)}% ($onTime/${returned.length})',
                            badge: onTimeRate == null ? '-' : (onTimeRate >= 0.9 ? 'Disiplin Tinggi' : 'Perlu Pengingat'),
                            good: onTimeRate != null && onTimeRate >= 0.9,
                          ),
                      ]),
                    ),
                  ],
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _duration(Duration d) {
    if (d.inMinutes < 60) return '${d.inMinutes} Menit';
    if (d.inHours < 24) return '${d.inHours} Jam ${d.inMinutes % 60} Menit';
    return '${d.inDays} Hari ${d.inHours % 24} Jam';
  }
}

class _CompletionBanner extends StatelessWidget {
  final int totalOrders;
  final int completedOrders;
  const _CompletionBanner({required this.totalOrders, required this.completedOrders});

  @override
  Widget build(BuildContext context) {
    final rate = totalOrders == 0 ? 0.0 : completedOrders / totalOrders;
    final good = rate >= 0.5;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: AppColors.beige, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        const Icon(Icons.auto_graph_rounded, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text.rich(TextSpan(children: [
            const TextSpan(text: 'Tingkat penyelesaian pesanan '),
            TextSpan(text: '${(rate * 100).toStringAsFixed(1)}%', style: TextStyle(fontWeight: FontWeight.w700, color: good ? AppColors.success : AppColors.warning)),
          ]), style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
        ),
        Text(good ? 'On-track' : 'Perlu Dorongan', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.goldDark)),
        const SizedBox(width: 4),
        Icon(good ? Icons.check_circle_outline_rounded : Icons.error_outline_rounded, size: 16, color: AppColors.goldDark),
      ]),
    );
  }
}

class _KpiGrid extends StatelessWidget {
  final _TypeFilter filter;
  final double revenue;
  final double? growth;
  final int totalOrders;
  final int completedOrders;
  final int pendingOrders;
  final int? orderDelta;
  final double utilization;
  final int rentedNow;
  final int totalStock;
  final int soldUnits;
  final int totalCustomers;
  final int sewaPct;

  const _KpiGrid({
    required this.filter,
    required this.revenue,
    required this.growth,
    required this.totalOrders,
    required this.completedOrders,
    required this.pendingOrders,
    required this.orderDelta,
    required this.utilization,
    required this.rentedNow,
    required this.totalStock,
    required this.soldUnits,
    required this.totalCustomers,
    required this.sewaPct,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(
            child: _Kpi(
              label: 'Total Omset',
              value: Formatters.rupiahCompact(revenue),
              caption: switch (filter) {
                _TypeFilter.semua => revenue == 0 ? 'Belum ada transaksi' : 'Beli ${100 - sewaPct}% • Sewa $sewaPct%',
                _TypeFilter.beli => revenue == 0 ? 'Belum ada transaksi' : '$totalOrders pesanan beli',
                _TypeFilter.sewa => revenue == 0 ? 'Belum ada transaksi' : '$totalOrders pesanan sewa',
              },
              badge: growth == null
                  ? null
                  : Text('${growth! >= 0 ? '+' : ''}${growth!.toStringAsFixed(1)}% ${growth! >= 0 ? '↗' : '↘'}',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: growth! >= 0 ? AppColors.success : AppColors.danger)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _Kpi(
              label: 'Pesanan Masuk',
              value: '$totalOrders',
              caption: '$completedOrders Selesai • $pendingOrders Pending',
              badge: orderDelta == null || orderDelta == 0
                  ? null
                  : VgPill(label: '${orderDelta! > 0 ? '+' : ''}$orderDelta', color: AppColors.textPrimary, background: AppColors.beige, fontSize: 11),
            ),
          ),
        ]),
      ),
      const SizedBox(height: 10),
      IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(
            child: filter == _TypeFilter.beli
                ? _Kpi(
                    label: 'Barang Terjual',
                    value: '$soldUnits Unit',
                    caption: 'Dari $totalOrders pesanan pembelian',
                  )
                : _Kpi(
                    label: 'Utilisasi Sewa',
                    value: '${(utilization * 100).toStringAsFixed(1)}%',
                    valueColor: AppColors.primary,
                    caption: totalStock == 0 ? 'Tidak ada unit sewa' : '$rentedNow dari $totalStock unit disewa',
                    captionDot: utilization >= 0.75 ? const Color(0xFFF59E0B) : null,
                    badge: utilization >= 0.75 ? const VgPill(label: 'Padat', color: AppColors.goldDark, background: AppColors.beige, fontSize: 11) : null,
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _Kpi(
              label: 'Pelanggan Terdaftar',
              value: '$totalCustomers',
              caption: 'Akun pelanggan aktif',
            ),
          ),
        ]),
      ),
    ]);
  }
}

class _Kpi extends StatelessWidget {
  final String label;
  final String value;
  final String caption;
  final Widget? badge;
  final Color valueColor;
  final Color? captionDot;

  const _Kpi({required this.label, required this.value, required this.caption, this.badge, this.valueColor = AppColors.textPrimary, this.captionDot});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border), boxShadow: AppColors.cardShadow),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary))),
          ?badge,
        ]),
        const SizedBox(height: 8),
        FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: valueColor))),
        const SizedBox(height: 6),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (captionDot != null) Container(margin: const EdgeInsets.only(top: 5, right: 5), width: 6, height: 6, decoration: BoxDecoration(color: captionDot, shape: BoxShape.circle)),
          Expanded(child: Text(caption, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.3))),
        ]),
      ]),
    );
  }
}

class _RevenueComposition extends StatelessWidget {
  final ReportSummary summary;
  final String Function(String) typeName;
  const _RevenueComposition({required this.summary, required this.typeName});

  @override
  Widget build(BuildContext context) {
    final entries = summary.revenueByType.entries.where((e) => e.value > 0).toList()..sort((a, b) => b.value.compareTo(a.value));
    final total = summary.totalRevenue;
    return VgCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Expanded(child: Text('Komposisi Pendapatan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
          Icon(Icons.pie_chart_outline_rounded, color: AppColors.primary),
        ]),
        const SizedBox(height: 14),
        if (entries.isEmpty || total == 0)
          const Text('Belum ada pembayaran terverifikasi pada periode ini.', style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary))
        else ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 12,
              child: Row(children: [
                for (final e in entries) Expanded(flex: (e.value / total * 1000).round().clamp(1, 1000), child: Container(color: _typeColors[e.key] ?? AppColors.success)),
              ]),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(runSpacing: 12, children: [
            for (final e in entries)
              FractionallySizedBox(
                widthFactor: 0.5,
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(margin: const EdgeInsets.only(top: 4), width: 9, height: 9, decoration: BoxDecoration(color: _typeColors[e.key] ?? AppColors.success, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(typeName(e.key), style: const TextStyle(fontSize: 12.5, color: AppColors.primary)),
                      Text('${(e.value / total * 100).round()}% (${Formatters.rupiahCompact(e.value)})', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    ]),
                  ),
                ]),
              ),
          ]),
        ],
      ]),
    );
  }
}

class _Efficiency extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String badge;
  final bool good;

  const _Efficiency({required this.icon, required this.label, required this.value, required this.badge, required this.good});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: VgInset(
        child: Row(children: [
          VgIconBadge(icon: icon, color: AppColors.primary, background: AppColors.surface, size: 36, circle: true),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: const TextStyle(fontSize: 12.5, color: AppColors.primary)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ]),
          ),
          const SizedBox(width: 8),
          VgPill(label: badge, color: good ? AppColors.success : AppColors.goldDark, background: AppColors.surface, fontSize: 11),
        ]),
      ),
    );
  }
}

