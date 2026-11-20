import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  LocalNotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;

  /// Callback navigasi saat notifikasi diklik pengguna di status bar
  static void Function(String? payload)? onNotificationTapped;

  static const String channelOrdersId = 'vieguard_orders_channel';
  static const String channelOrdersName = 'Pesanan & Transaksi';
  static const String channelOrdersDesc = 'Notifikasi saat ada pesanan baru, pembayaran DP, atau pelunasan';

  static const String channelChatId = 'vieguard_chat_channel';
  static const String channelChatName = 'Pesan Obrolan Pelanggan';
  static const String channelChatDesc = 'Notifikasi saat pelanggan mengirim pesan chat baru ke admin';

  static const String channelGeneralId = 'vieguard_general_channel';
  static const String channelGeneralName = 'Notifikasi Sistem';
  static const String channelGeneralDesc = 'Pemberitahuan umum sistem operasional Vieguard';

  static const Color _accentColor = Color(0xFF8E0A20);

  /// Inisialisasi awal notifikasi sistem
  static Future<void> initialize({void Function(String? payload)? onTap}) async {
    if (_isInitialized) return;
    onNotificationTapped = onTap;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false, // Diminta via onboarding permission dialog
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        onNotificationTapped?.call(response.payload);
      },
    );

    // Daftarkan Channel Android untuk prioritas tinggi & suara/getar
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      await androidImpl.createNotificationChannel(
        const AndroidNotificationChannel(
          channelOrdersId,
          channelOrdersName,
          description: channelOrdersDesc,
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        ),
      );
      await androidImpl.createNotificationChannel(
        const AndroidNotificationChannel(
          channelChatId,
          channelChatName,
          description: channelChatDesc,
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        ),
      );
      await androidImpl.createNotificationChannel(
        const AndroidNotificationChannel(
          channelGeneralId,
          channelGeneralName,
          description: channelGeneralDesc,
          importance: Importance.defaultImportance,
          playSound: true,
          enableVibration: true,
        ),
      );
    }

    _isInitialized = true;
    debugPrint('LocalNotificationService: Inisialisasi notifikasi berhasil.');
  }

  /// Tampilkan notifikasi umum
  static Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
    String channelId = channelGeneralId,
    String channelName = channelGeneralName,
  }) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: _accentColor,
        playSound: true,
        enableVibration: true,
        styleInformation: BigTextStyleInformation(
          body,
          contentTitle: title,
        ),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _plugin.show(id, title, body, details, payload: payload);
    } catch (e) {
      debugPrint('LocalNotificationService.show error: $e');
    }
  }

  /// Tampilkan notifikasi pesanan baru / transaksi
  static Future<void> showOrderNotification({
    required String title,
    required String message,
    String? orderId,
  }) async {
    final id = (DateTime.now().millisecondsSinceEpoch ~/ 1000) & 0x7FFFFFFF;
    debugPrint('[LocalNotificationService] Push Notifikasi Pesanan -> $title: $message');
    await show(
      id: id,
      title: '🛒 $title',
      body: message,
      payload: orderId != null ? 'order:$orderId' : 'orders',
      channelId: channelOrdersId,
      channelName: channelOrdersName,
    );
  }

  /// Tampilkan notifikasi obrolan / pesan baru dari pelanggan
  static Future<void> showChatNotification({
    required String customerName,
    required String messageText,
    String? conversationId,
  }) async {
    final id = (DateTime.now().millisecondsSinceEpoch ~/ 1000) & 0x7FFFFFFF;
    debugPrint('[LocalNotificationService] Push Notifikasi Chat -> $customerName: $messageText');
    await show(
      id: id,
      title: '💬 Pesan dari $customerName',
      body: messageText,
      payload: conversationId != null ? 'chat:$conversationId' : 'chat',
      channelId: channelChatId,
      channelName: channelChatName,
    );
  }
}
