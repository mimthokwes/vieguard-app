import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/local_notification_service.dart';
import '../../core/theme/app_theme.dart';
import '../../state/chat_provider.dart';
import '../../state/notification_provider.dart';
import '../../state/order_provider.dart';
import '../../widgets/common/tap_scale.dart';
import '../../widgets/dialogs/permission_dialog.dart';
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

    Future.microtask(() async {
      await _chat.fetchConversations();
      await _chat.connectRealtime();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      PermissionDialog.showIfNeeded(context);
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

  static const _items = [
    (Icons.window_outlined, 'Beranda'),
    (Icons.receipt_long_rounded, 'Beli'),
    (Icons.handshake_outlined, 'Sewa'),
    (Icons.chat_bubble_outline_rounded, 'Chat'),
    (Icons.trending_up_rounded, 'Laporan'),
    // (Icons.window_outlined,'Akun')
  ];

  @override
  Widget build(BuildContext context) {
    final unreadChats = context.watch<ChatProvider>().conversations.fold<int>(0, (s, c) => s + c.unreadCount);
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
        child: Container(
          height: 68,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.goldLight, width: 1.2),
            boxShadow: [BoxShadow(color: const Color(0xFF7A4A20).withValues(alpha: 0.12), blurRadius: 20, offset: const Offset(0, 6))],
          ),
          child: Row(
            children: List.generate(_items.length, (i) {
              final selected = i == _index;
              final (icon, label) = _items[i];
              return Expanded(
                child: TapScale(
                  onTap: () => setState(() {
                    _index = i;
                    _loadedIndices.add(i);
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: selected ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(18)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Badge(
                          isLabelVisible: label == 'Chat' && unreadChats > 0,
                          label: Text('${unreadChats > 99 ? '99+' : unreadChats}'),
                          backgroundColor: AppColors.danger,
                          child: Icon(icon, size: selected ? 22 : 24, color: selected ? AppColors.goldLight : AppColors.primary),
                        ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutCubic,
                          alignment: Alignment.center,
                          child: selected
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 3),
                                  child: Center(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        label,
                                        maxLines: 1,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.onPrimary,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
