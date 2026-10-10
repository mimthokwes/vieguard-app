import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/order_status.dart';
import '../../state/order_provider.dart';
import '../../widgets/vg/vg_form.dart';
import '../../widgets/vg/vg_ui.dart';
import '../pembayaran/payment_verification_detail_screen.dart';

const _methods = ['BCA Transfer', 'BRI Transfer', 'Mandiri Transfer', 'QRIS', 'Tunai'];

class SettlementScreen extends StatefulWidget {
  final String orderId;
  const SettlementScreen({super.key, required this.orderId});

  @override
  State<SettlementScreen> createState() => _SettlementScreenState();
}

class _SettlementScreenState extends State<SettlementScreen> {
  final _amount = TextEditingController();
  String _method = _methods.first;
  XFile? _proof;
  bool _received = false;
  bool _saving = false;
  bool _reminding = false;
  bool _initialized = false;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  double get _enteredAmount => double.tryParse(_amount.text.replaceAll('.', '')) ?? 0;

  Future<void> _confirm(double remaining) async {
    final provider = context.read<OrderProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final amount = _enteredAmount;
    if (amount <= 0 || amount > remaining) {
      messenger.showSnackBar(SnackBar(content: Text('Nominal harus antara Rp 1 dan ${Formatters.rupiah(remaining)}.')));
      return;
    }
    if (!_received) {
      messenger.showSnackBar(const SnackBar(content: Text('Centang konfirmasi bahwa dana sudah diterima.')));
      return;
    }
    setState(() => _saving = true);
    final ok = await provider.recordPayment(widget.orderId, paymentType: 'pelunasan', amount: amount, paymentMethod: _method, proof: _proof);
    if (!mounted) return;
    setState(() => _saving = false);
    messenger.showSnackBar(SnackBar(content: Text(ok ? 'Pelunasan ${Formatters.rupiah(amount)} tercatat.' : provider.errorMessage ?? 'Gagal mencatat pelunasan.')));
    if (ok) navigator.pop();
  }

  Future<void> _remind() async {
    final provider = context.read<OrderProvider>();
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _reminding = true);
    final ok = await provider.remindPayment(widget.orderId);
    if (!mounted) return;
    setState(() => _reminding = false);
    messenger.showSnackBar(SnackBar(content: Text(ok ? 'Pengingat pelunasan dikirim ke pelanggan.' : provider.errorMessage ?? 'Gagal mengirim pengingat.')));
  }

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrderProvider>().orderById(widget.orderId);
    if (order == null) {
      return const Scaffold(backgroundColor: AppColors.background, appBar: VgBackBar(title: 'Konfirmasi Pelunasan'), body: Center(child: Text('Pesanan tidak ditemukan.')));
    }
    final remaining = order.sisaTagihan;
    if (!_initialized) {
      _initialized = true;
      _amount.text = Formatters.rupiah(remaining).replaceFirst('Rp ', '');
    }
    final pending = order.pendingPayment;
    final verified = order.payments.where((p) => p.status == PaymentStatus.terverifikasi).toList();
    final lunas = remaining <= 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const VgBackBar(title: 'Konfirmasi Pelunasan'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          VgCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wrap(spacing: 8, runSpacing: 6, children: [
                VgPill(label: '#${order.orderNumber}', color: AppColors.primary, background: AppColors.beige, fontSize: 11),
                lunas
                    ? const VgPill(label: 'Lunas', color: AppColors.success, background: AppColors.successBg, dot: true, fontSize: 11)
                    : const VgPill(label: 'Menunggu Pelunasan', color: AppColors.warning, background: AppColors.warningBg, dot: true, fontSize: 11),
              ]),
              const SizedBox(height: 10),
              Text(order.customer.name, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              Text('${order.headline} (${order.totalQuantity} Stel)', style: const TextStyle(fontSize: 12.5, color: AppColors.primary)),
              if (order.requiresProduction) ...[
                const SizedBox(height: 12),
                VgInset(
                  child: Row(children: [
                    const Icon(Icons.precision_manufacturing_outlined, color: AppColors.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(child: Text('Status Produksi: ${order.latestProgress}%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
                    if (order.latestProgress >= 100) const VgPill(label: 'Selesai', color: AppColors.success, background: AppColors.surface, fontSize: 11),
                  ]),
                ),
              ],
            ]),
          ),
          VgCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const VgCardTitle(title: 'Rincian Tagihan', trailing: VgIconBadge(icon: Icons.receipt_long_outlined, size: 36)),
              _Line(label: 'Total Nilai Pesanan', value: Formatters.rupiah(order.totalPrice)),
              for (final p in verified)
                _Line(
                  label: '${p.paymentType == 'dp' ? 'DP' : 'Pelunasan'} • ${p.paymentMethod ?? '-'}${p.verifiedAt != null ? ' (${Formatters.date(p.verifiedAt!)})' : ''}',
                  value: '- ${Formatters.rupiah(p.amount)}',
                  valueColor: AppColors.success,
                ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(gradient: AppColors.maroonGradient, borderRadius: BorderRadius.circular(16)),
                child: Row(children: [
                  const Expanded(child: Text('SISA TAGIHAN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.goldLight, letterSpacing: 0.6))),
                  Text(Formatters.rupiah(remaining), style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: Colors.white)),
                ]),
              ),
            ]),
          ),
          if (pending != null)
            VgCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const VgCardTitle(title: 'Bukti Transfer Pelanggan', subtitle: 'Pelanggan sudah mengunggah bukti, verifikasi terlebih dahulu'),
                VgInset(
                  child: Row(children: [
                    const Icon(Icons.hourglass_top_rounded, color: AppColors.warning, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text('${pending.paymentType == 'dp' ? 'DP' : 'Pelunasan'} ${Formatters.rupiah(pending.amount)} • ${pending.paymentMethod ?? '-'}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    ),
                  ]),
                ),
              ]),
            )
          else if (!lunas)
            VgCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const VgCardTitle(title: 'Catat Pelunasan Diterima', subtitle: 'Untuk pembayaran yang sudah masuk ke rekening atau kas'),
                const VgLabel('Metode Pembayaran'),
                VgChoiceChips<String>(options: [for (final m in _methods) (m, m)], selected: _method, onSelected: (v) => setState(() => _method = v)),
                const SizedBox(height: 12),
                const VgLabel('Nominal Diterima'),
                VgMoneyField(controller: _amount, onChanged: (_) => setState(() {})),
                const SizedBox(height: 12),
                const VgLabel('Bukti Transfer (opsional)'),
                SizedBox(
                  height: 110,
                  child: Row(children: [
                    Expanded(
                      child: _proof != null
                          ? VgPhotoTile(file: _proof, caption: 'Bukti pelunasan', onRemove: () => setState(() => _proof = null))
                          : VgAddPhotoTile(
                              label: '+ Foto Bukti',
                              onTap: () async {
                                final picked = await pickPhotos(context, multiple: false);
                                if (picked.isNotEmpty) setState(() => _proof = picked.first);
                              },
                            ),
                    ),
                  ]),
                ),
                const SizedBox(height: 12),
                VgSwitchRow(
                  title: 'Dana sudah diterima',
                  subtitle: 'Saya sudah mengecek mutasi rekening / kas VIEGUARD',
                  value: _received,
                  onChanged: (v) => setState(() => _received = v),
                ),
              ]),
            ),
        ],
      ),
      bottomNavigationBar: lunas
          ? null
          : VgBottomBar(children: [
              if (pending != null)
                VgButton(
                  label: 'Tinjau Bukti Transfer',
                  icon: Icons.fact_check_outlined,
                  style: VgButtonStyle.green,
                  expanded: true,
                  height: 50,
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentVerificationDetailScreen(paymentId: pending.id))),
                )
              else
                VgButton(
                  label: 'Konfirmasi Pelunasan ${Formatters.rupiah(_enteredAmount)}',
                  icon: Icons.verified_outlined,
                  style: VgButtonStyle.green,
                  expanded: true,
                  height: 50,
                  loading: _saving,
                  onPressed: () => _confirm(remaining),
                ),
              const SizedBox(height: 10),
              VgButton(
                label: 'Kirim Pengingat ke Pelanggan',
                icon: Icons.notifications_active_outlined,
                style: VgButtonStyle.soft,
                expanded: true,
                height: 42,
                loading: _reminding,
                onPressed: _remind,
              ),
            ]),
    );
  }
}

class _Line extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  const _Line({required this.label, required this.value, this.valueColor = AppColors.textPrimary});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.primary))),
        const SizedBox(width: 8),
        Text(value, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: valueColor)),
      ]),
    );
  }
}
