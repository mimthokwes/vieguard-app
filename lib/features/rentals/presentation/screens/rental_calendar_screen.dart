import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import 'rental_list_screen.dart';
import 'rental_stock_management_screen.dart';
import 'rental_detail_screen.dart';
import 'item_condition_form_screen.dart';

import '../../../../core/providers/rental_provider.dart';

class RentalCalendarScreen extends StatefulWidget {
  const RentalCalendarScreen({super.key});

  @override
  State<RentalCalendarScreen> createState() => _RentalCalendarScreenState();
}

class _RentalCalendarScreenState extends State<RentalCalendarScreen> {
  final RentalProvider _rentalProvider = RentalProvider();
  int _selectedDay = 24;

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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomHeaderAppBar(subtitle: 'Penyewaan Alat'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Booking Jadwal Sewa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Tabs
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
                    child: _buildHeaderTab(
                      label: 'Daftar Sewa',
                      isSelected: false,
                      onTap: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const RentalListScreen()));
                      },
                    ),
                  ),
                  Expanded(
                    child: _buildHeaderTab(
                      label: 'Kalender Jadwal',
                      isSelected: true,
                      onTap: () {},
                    ),
                  ),
                  Expanded(
                    child: _buildHeaderTab(
                      label: 'Katalog Stok',
                      isSelected: false,
                      onTap: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const RentalStockManagementScreen()));
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Calendar Card View
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.calendar_month, color: AppColors.primary, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Oktober 2024',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(icon: const Icon(Icons.chevron_left), onPressed: () {}),
                          IconButton(icon: const Icon(Icons.chevron_right), onPressed: () {}),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Days Header (Sen - Sel - Rab...)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      Text('Sen', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      Text('Sel', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      Text('Rab', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      Text('Kam', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      Text('Jum', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      Text('Sab', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      Text('Min', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Calendar Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 31,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemBuilder: (context, index) {
                      final day = index + 1;
                      final isSelected = day == _selectedDay;

                      return GestureDetector(
                        onTap: () => setState(() => _selectedDay = day),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$day',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? Colors.white : AppColors.textPrimary,
                                ),
                              ),
                              if (day == 1 || day == 8 || day == 15 || day == 21 || day == 24 || day == 28) ...[
                                const SizedBox(height: 2),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (day == 24 || day == 1 || day == 15)
                                      const CircleAvatar(radius: 2, backgroundColor: AppColors.accentBlue),
                                    if (day == 24 || day == 10 || day == 17) ...[
                                      const SizedBox(width: 2),
                                      const CircleAvatar(radius: 2, backgroundColor: AppColors.accentGreen),
                                    ],
                                    if (day == 24 || day == 5 || day == 12 || day == 19 || day == 26) ...[
                                      const SizedBox(width: 2),
                                      const CircleAvatar(radius: 2, backgroundColor: AppColors.accentOrange),
                                    ],
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 14),

                  // Calendar Legend Bar
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const [
                        Row(children: [CircleAvatar(radius: 4, backgroundColor: AppColors.accentBlue), SizedBox(width: 4), Text('Pengambilan', style: TextStyle(fontSize: 10))]),
                        Row(children: [CircleAvatar(radius: 4, backgroundColor: AppColors.accentGreen), SizedBox(width: 4), Text('Pengembalian', style: TextStyle(fontSize: 10))]),
                        Row(children: [CircleAvatar(radius: 4, backgroundColor: AppColors.accentOrange), SizedBox(width: 4), Text('Jadwal Penuh', style: TextStyle(fontSize: 10))]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Agenda List Header
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.event_note_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Agenda Kamis, $_selectedDay Oktober 2024',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                    child: const Text('Hari Ini', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Agenda Item 1: 09:00 WIB
            _buildAgendaCard(
              time: '09:00 WIB',
              badgeLabel: 'AMBIL',
              badgeType: BadgeType.info,
              title: 'SMP Negeri 1 Surabaya',
              desc: '18 Stel Kostum Pahlawan Pejuang',
              pill1: 'Diambil Bpk. Joko',
              pill2: 'Selesai Diambil',
              isPill2Green: true,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const RentalDetailScreen()));
              },
            ),
            const SizedBox(height: 10),

            // Agenda Item 2: 13:30 WIB
            _buildAgendaCard(
              time: '13:30 WIB',
              badgeLabel: 'KEMBALI',
              badgeType: BadgeType.success,
              title: 'Sanggar Tari Gayatri',
              desc: '12 Stel Kostum Gandrung',
              pill1: 'Dalam Pengecekan',
              pill2: 'Staff: Mbak Rina',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ItemConditionFormScreen()));
              },
            ),
            const SizedBox(height: 10),

            // Agenda Item 3: 15:00 WIB
            _buildAgendaCard(
              time: '15:00 WIB',
              badgeLabel: 'FITTING',
              badgeType: BadgeType.warning,
              title: 'SMK Telkom Malang',
              desc: 'Fitting 8 Pasang Jas Paduan Suara',
              pill1: 'Ruang Fitting 2',
              pill2: 'PJ: Kak Dimas',
            ),
            const SizedBox(height: 10),

            // Agenda Item 4: 17:00 WIB
            _buildAgendaCard(
              time: '17:00 WIB',
              badgeLabel: 'KEMBALI',
              badgeType: BadgeType.neutral,
              title: 'SMA Taruna Bangsa',
              desc: '10 Stel Drumband',
              pill1: 'Menunggu Kurir Tiba',
              pill2: 'Lalamove Cargo',
            ),
            const SizedBox(height: 16),

            // Okupansi Kostum Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.cardBorder)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.pie_chart_outline_rounded, color: AppColors.primary, size: 18),
                          SizedBox(width: 8),
                          Text('Okupansi Kostum', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        ],
                      ),
                      Text('82%', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: const LinearProgressIndicator(
                      value: 0.82,
                      minHeight: 8,
                      backgroundColor: Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('142 terbooking dari 175 stel kostum', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      Text('• Akhir Pekan Padat', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accentOrange)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Info Workshop Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.cardBorder)),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(10),
                      image: const DecorationImage(
                        image: NetworkImage('https://images.unsplash.com/photo-1594938298603-c8148c4dae35?auto=format&fit=crop&w=150&q=80'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ruang Fitting & Quality Control', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        Text('Semua kostum telah disterilisasi ozon & disetrika uap sebelum serah terima.', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderTab({required String label, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.white : AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildAgendaCard({
    required String time,
    required String badgeLabel,
    required BadgeType badgeType,
    required String title,
    required String desc,
    required String pill1,
    required String pill2,
    bool isPill2Green = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.cardBorder)),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(time, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                AppBadge(label: badgeLabel, type: badgeType),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  Text(desc, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(6)),
                        child: Text(pill1, style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isPill2Green ? AppColors.accentGreenBg : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          pill2,
                          style: TextStyle(fontSize: 10, color: isPill2Green ? AppColors.accentGreen : AppColors.textSecondary, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}
