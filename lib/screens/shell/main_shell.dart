import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/local_notification_service.dart';
import '../../core/theme/app_theme.dart';
import '../../state/chat_provider.dart';
import '../../state/notification_provider.dart';
import '../../state/order_provider.dart';
import '../../widgets/dialogs/permission_dialog.dart';
import '../../widgets/navigation/floating_notch_nav_bar.dart';
import '../laporan/laporan_screen.dart';
import '../beranda/beranda_screen.dart';
import '../chat/chat_list_screen.dart';
import '../penyewaan/penyewaan_list_screen.dart';
import '../pesanan/detail_pesanan_screen.dart';
import '../pesanan/pesanan_list_screen.dart';
// import '../laporan/laporan_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  final Set<int> _loadedIndices = {0};
  late final ChatProvider _chat;

  @override
  void initState() {
    super.initState();
    _chat = context.read<ChatProvider>();

    _chat.onNotificationReceived = () {
      if (!mounted) return;
      context.read<NotificationProvider>().fetchNotifications(force: true);
      context.read<OrderProvider>().fetchOrders(force: true);
    };

    LocalNotificationService.onNotificationTapped = (payload) {
      if (!mounted || payload == null) return;
      if (payload.startsWith('order:')) {
        final orderId = payload.substring(6);
        setState(() {
          _index = 1;
          _loadedIndices.add(1);
        });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailPesananScreen(orderId: orderId)),
        );
      } else if (payload.startsWith('chat')) {
        setState(() {
          _index = 3;
          _loadedIndices.add(3);
        });
      } else if (payload == 'orders') {
        setState(() {
          _index = 1;
          _loadedIndices.add(1);
        });
      }
    };

    WidgetsBinding.instance.addPostFrameCallback((_) {
      PermissionDialog.showIfNeeded(context);
      // Tunda network socket chat sejenak agar frame pertama & transisi halaman berjalan mulus
      Future.delayed(const Duration(milliseconds: 450), () async {
        if (!mounted) return;
        await _chat.fetchConversations();
        await _chat.connectRealtime();
      });
    });
  }

  @override
  void dispose() {
    _chat.onNotificationReceived = null;
    LocalNotificationService.onNotificationTapped = null;
    _chat.disconnectRealtime();
    super.dispose();
  }

  static const _screens = [
    BerandaScreen(),
    PesananListScreen(),
    PenyewaanListScreen(),
    ChatListScreen(),
    LaporanScreen(),
    // AkunScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final unreadChats = context.select<ChatProvider, int>(
      (chat) => chat.conversations.fold<int>(0, (s, c) => s + c.unreadCount),
    );
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _index,
        children: List.generate(
          _screens.length,
          (i) => _loadedIndices.contains(i) ? _screens[i] : const SizedBox.shrink(),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        child: FloatingNotchNavBar(
          currentIndex: _index,
          onTap: (i) => setState(() {
            _index = i;
            _loadedIndices.add(i);
          }),
          items: [
            const FloatingNotchItem(icon: Icons.window_outlined, label: 'Beranda'),
            const FloatingNotchItem(icon: Icons.receipt_long_rounded, label: 'Beli'),
            const FloatingNotchItem(icon: Icons.handshake_outlined, label: 'Sewa'),
            FloatingNotchItem(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'Chat',
              badgeCount: unreadChats,
            ),
            const FloatingNotchItem(icon: Icons.trending_up_rounded, label: 'Laporan'),
          ],
        ),
      ),
    );
  }
}
