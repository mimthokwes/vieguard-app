import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../tools/presentation/screens/size_data_preview_screen.dart';
import '../../../orders/presentation/screens/order_detail_standard_screen.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({super.key});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryLight,
              child: const Text('SB', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Bpk. Bambang (SMP Brawijaya)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                Text('Online • Responsif', style: TextStyle(fontSize: 10, color: AppColors.accentGreen)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Linked Order Banner Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.white,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 16, color: AppColors.primary),
                          SizedBox(width: 6),
                          Text('Pesanan #VG-2024-0891', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const OrderDetailStandardScreen()));
                        },
                        child: const Row(
                          children: [
                            Text('Lihat Pesanan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                            Icon(Icons.chevron_right, size: 14, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('Paket Drumband (36 Stel) • Total: Rp 7.200.000', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  const Row(
                    children: [
                      AppBadge(label: 'Menunggu Konfirmasi', type: BadgeType.warning),
                      SizedBox(width: 6),
                      AppBadge(label: 'DP: Terverifikasi', type: BadgeType.success),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Messages View
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Date separator
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.cardBorder)),
                    child: const Text('Kamis, 24 Oktober 2024', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ),
                ),
                const SizedBox(height: 16),

                // Incoming Message 1
                _buildIncomingBubble(
                  senderName: 'Bpk. Bambang Hernanto',
                  senderSub: '(SMP Brawijaya)',
                  time: '10:15 WIB',
                  text: 'Halo Admin VIEGUARD, kami sudah mendiskusikan kembali dengan komite sekolah mengenai pesanan 36 stel seragam Drumband Gita Bahari.',
                ),
                const SizedBox(height: 12),

                // Outgoing Message 1
                _buildOutgoingBubble(
                  time: '10:20 WIB',
                  text: 'Halo Bapak Bambang, terima kasih atas konfirmasinya. Apakah ada catatan revisi atau data ukuran anak-anak yang perlu disesuaikan?',
                ),
                const SizedBox(height: 12),

                // Incoming Message 2 with Excel Attachment
                _buildIncomingBubble(
                  senderName: 'Bpk. Bambang Hernanto',
                  time: '10:38 WIB',
                  text: 'Ini file data ukuran siswa terbaru yang sudah kami isi sesuai template Excel resmi dari VIEGUARD. Mohon dicek ya min.',
                  attachmentWidget: Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.accentGreenBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.accentGreenBorder)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.grid_on_rounded, color: AppColors.accentGreen, size: 24),
                            SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('data_ukuran_smp_brawijaya_final.xlsx', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                  Text('48 KB • 36 Data Siswa • 24 Okt 10:37', style: TextStyle(fontSize: 9, color: AppColors.textMuted)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.download, size: 12, color: Colors.white),
                                label: const Text('Unduh', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 4)),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SizeDataPreviewScreen()));
                                },
                                icon: const Icon(Icons.remove_red_eye, size: 12, color: AppColors.primary),
                                label: const Text('Pratinjau', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 4)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Outgoing Message 2
                _buildOutgoingBubble(
                  time: '10:41 WIB',
                  text: 'Baik Pak Bambang, file sudah kami terima. Sedang kami verifikasi kelengkapan size-nya di sistem konveksi kami.',
                ),
                const SizedBox(height: 14),

                // System Auto-Validation Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.primaryBorder)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.bolt_rounded, color: AppColors.primary, size: 20),
                          SizedBox(width: 8),
                          Text('Validasi Otomatis Berhasil', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          Spacer(),
                          AppBadge(label: '100% Cocok', type: BadgeType.success),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '36/36 Siswa telah memiliki ukuran lengkap (S: 10, M: 18, L: 8). Siap masuk antrean produksi!',
                        style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        text: 'Teruskan ke Produksi',
                        icon: Icons.precision_manufacturing_outlined,
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const OrderDetailStandardScreen()));
                        },
                        isPrimary: true,
                        height: 40,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Quick Action Pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                _buildQuickActionChip('Minta Bukti Transfer', Icons.receipt_long),
                const SizedBox(width: 6),
                _buildQuickActionChip('Kirim Template Excel', Icons.table_chart),
                const SizedBox(width: 6),
                _buildQuickActionChip('Kirim Penawaran', Icons.description),
              ],
            ),
          ),

          // Text Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.add, color: AppColors.primary), onPressed: () {}),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(24)),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Ketik pesan balasan...',
                        hintStyle: TextStyle(fontSize: 13, color: AppColors.textMuted),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ),
                IconButton(icon: const Icon(Icons.mic_none_rounded, color: AppColors.textMuted), onPressed: () {}),
                Container(
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                    onPressed: () {
                      if (_messageController.text.isNotEmpty) {
                        setState(() {
                          _messageController.clear();
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomingBubble({
    required String senderName,
    String? senderSub,
    required String time,
    required String text,
    Widget? attachmentWidget,
  }) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(senderName, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                Text(time, style: const TextStyle(fontSize: 9, color: AppColors.textMuted)),
              ],
            ),
            const SizedBox(height: 4),
            Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
            if (attachmentWidget != null) attachmentWidget,
          ],
        ),
      ),
    );
  }

  Widget _buildOutgoingBubble({required String time, required String text}) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(text, style: const TextStyle(fontSize: 12, color: Colors.white)),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(time, style: const TextStyle(fontSize: 9, color: Colors.white70)),
                const SizedBox(width: 4),
                const Icon(Icons.done_all, size: 12, color: Colors.white70),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionChip(String label, IconData icon) {
    return ActionChip(
      avatar: Icon(icon, size: 14, color: AppColors.primary),
      label: Text(label, style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold)),
      backgroundColor: AppColors.primaryLight,
      side: const BorderSide(color: AppColors.primaryBorder),
      onPressed: () {},
    );
  }
}
