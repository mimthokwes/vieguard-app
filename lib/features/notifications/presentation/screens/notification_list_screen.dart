import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/providers/notification_provider.dart';
import '../../../../core/models/notification_model.dart';
import '../../../tools/presentation/screens/size_data_preview_screen.dart';
import '../../../payments/presentation/screens/payment_verification_screen.dart';
import '../../../rentals/presentation/screens/rental_calendar_screen.dart';

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  final NotificationProvider _notificationProvider = NotificationProvider();
  int _selectedFilterIndex = 0;

  @override
  void initState() {
    super.initState();
    _notificationProvider.fetchNotifications();
    _notificationProvider.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifications = _notificationProvider.notifications;
    final List<String> filters = [
      'Semua (${notifications.length})',
      'Belum Dibaca (${notifications.where((n) => !n.isRead).length})',
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifikasi & Log Aktivitas'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Pills Row
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
                      labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textSecondary, fontSize: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? AppColors.primary : AppColors.cardBorder)),
                      showCheckmark: false,
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const CircleAvatar(radius: 4, backgroundColor: AppColors.accentBlue),
                    const SizedBox(width: 6),
                    Text('${notifications.length} notifikasi dari backend', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Semua notifikasi ditandai dibaca.')));
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.done_all, size: 14, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text('Tandai Semua Dibaca', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Dynamic Items from Provider
            if (_notificationProvider.isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
            else if (notifications.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.cardBorder)),
                child: const Text('Belum ada notifikasi di backend.', style: TextStyle(color: AppColors.textMuted)),
              )
            else
              Column(
                children: List.generate(notifications.length, (index) {
                  final NotificationModel notif = notifications[index];
                  IconData iconData = Icons.notifications_none_rounded;
                  Color iconBg = AppColors.primaryLight;
                  Color iconFg = AppColors.primary;

                  if (notif.type == 'payment' || notif.type == 'PAYMENT_VERIFIED') {
                    iconData = Icons.account_balance_outlined;
                    iconBg = AppColors.accentGreenBg;
                    iconFg = AppColors.accentGreen;
                  } else if (notif.type == 'rental' || notif.type == 'RENTAL_RETURN') {
                    iconData = Icons.calendar_today_rounded;
                    iconBg = AppColors.accentOrangeBg;
                    iconFg = AppColors.accentOrange;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildNotificationCard(
                      context,
                      icon: iconData,
                      iconBg: iconBg,
                      iconFg: iconFg,
                      title: notif.title,
                      time: notif.createdAt.isNotEmpty ? notif.createdAt : 'Baru',
                      desc: notif.message,
                      actionButtons: [
                        Expanded(
                          child: AppButton(
                            text: 'Lihat Detail',
                            onPressed: () {
                              if (notif.type == 'payment' || notif.type == 'PAYMENT_VERIFIED') {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentVerificationScreen()));
                              } else if (notif.type == 'rental' || notif.type == 'RENTAL_RETURN') {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const RentalCalendarScreen()));
                              } else {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const SizeDataPreviewScreen()));
                              }
                            },
                            isPrimary: true,
                            height: 38,
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

  Widget _buildNotificationCard(
    BuildContext context, {
    required IconData icon,
    required Color iconBg,
    required Color iconFg,
    required String title,
    required String time,
    required String desc,
    required List<Widget> actionButtons,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                child: Icon(icon, size: 20, color: iconFg),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
                        Text(time, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(children: actionButtons),
        ],
      ),
    );
  }
}
