import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/providers/payment_provider.dart';
import '../../../../core/models/payment_model.dart';

class PaymentVerificationScreen extends StatefulWidget {
  const PaymentVerificationScreen({super.key});

  @override
  State<PaymentVerificationScreen> createState() => _PaymentVerificationScreenState();
}

class _PaymentVerificationScreenState extends State<PaymentVerificationScreen> {
  final PaymentProvider _paymentProvider = PaymentProvider();
  bool _checkNominal = true;
  bool _checkMutasi = true;
  bool _checkAlamat = true;

  @override
  void initState() {
    super.initState();
    _paymentProvider.fetchPayments();
    _paymentProvider.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final payments = _paymentProvider.payments;
    final PaymentModel? activePayment = payments.isNotEmpty ? payments.first : null;

    final customerName = activePayment?.customerName ?? 'SD Pertiwi Mandiri';
    final orderNo = activePayment?.orderNumber ?? '#VG-2024-0885';
    final amount = activePayment?.amount ?? 4650000;
    final status = activePayment?.status ?? 'menunggu';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Audit Pembayaran'),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_paymentProvider.isLoading)
              const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())
            else ...[
              // Header Info Card
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
                        AppBadge(label: 'STATUS: ${status.toUpperCase()}', type: status == 'terverifikasi' ? BadgeType.success : BadgeType.warning),
                        const Text('Live Backend Data', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(customerName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    Text('Order No • $orderNo', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.accentGreenBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.local_shipping_outlined, color: AppColors.accentGreen, size: 20),
                          SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Status Produksi', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                              Text('Selesai 100% • Siap Kirim', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            ],
                          ),
                          Spacer(),
                          AppBadge(label: 'QC Passed', type: BadgeType.success),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Rincian Tagihan & Pelunasan Card
              _buildSectionCard(
                title: 'Rincian Tagihan & Pelunasan',
                subtitle: 'Termin Pembayaran Backend',
                icon: Icons.receipt_long_outlined,
                badge: const AppBadge(label: 'Termin Aktif', type: BadgeType.info),
                child: Column(
                  children: [
                    _buildBillingRow('Total Tagihan', 'Rp ${amount.toStringAsFixed(0)}'),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppColors.accentGreenBg, borderRadius: BorderRadius.circular(8)),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.check_circle, size: 14, color: AppColors.accentGreen),
                              SizedBox(width: 6),
                              Text('DP / Verifikasi Masuk Terbaca', style: TextStyle(fontSize: 10, color: AppColors.accentGreen, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Text('Status: Ok', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.accentGreen)),
                        ],
                      ),
                    ),
                    const Divider(height: 20, color: AppColors.cardBorder),

                    // Total Box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Total Transfer Ditagihkan', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                              Text('Validasi Otomatis API', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                            ],
                          ),
                          Text('Rp ${amount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Bukti Transfer Pelanggan Card
              _buildSectionCard(
                title: 'Bukti Transfer Pelanggan',
                subtitle: 'Data Mutasi Transaksi Masuk',
                icon: Icons.account_balance_outlined,
                badge: const AppBadge(label: 'Match 100%', type: BadgeType.warning),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTransferInfoRow('Nama Pemilik', customerName),
                    _buildTransferInfoRow('No. Order', orderNo),
                    _buildTransferInfoRow('Nominal Tertera', 'Rp ${amount.toStringAsFixed(0)}', isGreen: true),
                    const SizedBox(height: 12),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primaryBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('m-Transfer Bank', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary)),
                              AppBadge(label: 'BERHASIL', type: BadgeType.success),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text('Order: $orderNo', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          const SizedBox(height: 8),
                          Text('Jumlah Ditransfer: Rp ${amount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                          const SizedBox(height: 14),
                          AppButton(
                            text: 'Perbesar Bukti Transfer Asli',
                            icon: Icons.zoom_in_rounded,
                            onPressed: () {},
                            isPrimary: false,
                            isOutline: true,
                            height: 40,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Audit Kepatuhan & Validasi Card
              _buildSectionCard(
                title: 'Audit Kepatuhan & Validasi',
                subtitle: 'Pastikan ketiga butir di bawah telah dicek secara cermat',
                icon: Icons.fact_check_outlined,
                badge: const AppBadge(label: '3/3 Lengkap', type: BadgeType.success),
                child: Column(
                  children: [
                    _buildCheckboxTile(
                      title: 'Nominal transfer pas dan sesuai invoice',
                      subtitle: 'Rp ${amount.toStringAsFixed(0)} sesuai dengan invoice final sistem.',
                      value: _checkNominal,
                      onChanged: (val) => setState(() => _checkNominal = val ?? false),
                    ),
                    const SizedBox(height: 8),
                    _buildCheckboxTile(
                      title: 'Mutasi rekening admin BCA telah dicek',
                      subtitle: 'Dana efektif masuk tanpa ada flag hold / pending kliring.',
                      value: _checkMutasi,
                      onChanged: (val) => setState(() => _checkMutasi = val ?? false),
                    ),
                    const SizedBox(height: 8),
                    _buildCheckboxTile(
                      title: 'Data alamat & kontak ekspedisi terkonfirmasi',
                      subtitle: 'PIC Pelanggan ($customerName) siap menerima pengiriman.',
                      value: _checkAlamat,
                      onChanged: (val) => setState(() => _checkAlamat = val ?? false),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Bottom Actions
              AppButton(
                text: 'Verifikasi & Terbitkan Resi Pengiriman',
                icon: Icons.local_shipping_rounded,
                onPressed: () async {
                  if (activePayment != null) {
                    final success = await _paymentProvider.verifyPayment(activePayment.id, 'terverifikasi');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(success ? 'Pembayaran berhasil diverifikasi di backend!' : 'Gagal verifikasi pembayaran.')),
                      );
                    }
                  }
                },
                isSuccess: true,
                height: 50,
              ),
              const SizedBox(height: 20),
            ],
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
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
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

  Widget _buildBillingRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildTransferInfoRow(String label, String value, {bool isGreen = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isGreen ? AppColors.accentGreen : AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildCheckboxTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: value ? AppColors.primaryLight : AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: value ? AppColors.primaryBorder : AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
