import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import 'local_notification_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
    debugPrint('[FCM Background] Menerima pesan: ${message.messageId}');
  } catch (e) {
    debugPrint('[FCM Background] Error inisialisasi di background: $e');
  }
}

class FcmService {
  FcmService._();

  static bool _isInitialized = false;

  /// Inisialisasi awal Firebase dan Firebase Cloud Messaging
  static Future<void> initialize({required ApiClient apiClient}) async {
    if (_isInitialized) return;

    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      final messaging = FirebaseMessaging.instance;

      // 1. Minta izin notifikasi (khusus Android 13+ & iOS)
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('[FCM] Status izin notifikasi pengguna: ${settings.authorizationStatus}');

      // 2. Ambil token perangkat dan daftarkan ke backend
      await syncTokenWithBackend(apiClient);

      // 3. Pasang listener jika token FCM diperbarui oleh Google
      messaging.onTokenRefresh.listen((newToken) async {
        debugPrint('[FCM] Token FCM diperbarui Google: $newToken');
        await sendTokenToBackend(apiClient, newToken);
      });

      // 4. Tangani pesan masuk saat aplikasi aktif di layar depan (Foreground)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('[FCM Foreground] Pesan masuk: ${message.notification?.title} - ${message.notification?.body}');
        final notif = message.notification;
        if (notif != null) {
          final data = message.data;
          final channelId = data['type'] == 'chat'
              ? LocalNotificationService.channelChatId
              : LocalNotificationService.channelOrdersId;
          final channelName = data['type'] == 'chat'
              ? LocalNotificationService.channelChatName
              : LocalNotificationService.channelOrdersName;

          String? payload;
          if (data['orderId'] != null) {
            payload = 'order:${data['orderId']}';
          } else if (data['conversationId'] != null) {
            payload = 'chat:${data['conversationId']}';
          }

          int notifId = 1001;
          if (data['orderId'] != null && data['orderId'].toString().isNotEmpty) {
            notifId = data['orderId'].toString().hashCode & 0x7FFFFFFF;
          } else if (data['conversationId'] != null && data['conversationId'].toString().isNotEmpty) {
            notifId = data['conversationId'].toString().hashCode & 0x7FFFFFFF;
          }

          LocalNotificationService.show(
            id: notifId,
            title: notif.title ?? 'VIEGUARD',
            body: notif.body ?? '',
            payload: payload,
            channelId: channelId,
            channelName: channelName,
          );
        }
      });

      // 5. Tangani ketika notifikasi diklik saat aplikasi di background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        final data = message.data;
        if (data['orderId'] != null) {
          LocalNotificationService.onNotificationTapped?.call('order:${data['orderId']}');
        } else if (data['conversationId'] != null) {
          LocalNotificationService.onNotificationTapped?.call('chat:${data['conversationId']}');
        }
      });

      // 6. Tangani jika aplikasi dibuka dari kondisi mati total via klik notifikasi
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        final data = initialMessage.data;
        if (data['orderId'] != null) {
          LocalNotificationService.onNotificationTapped?.call('order:${data['orderId']}');
        } else if (data['conversationId'] != null) {
          LocalNotificationService.onNotificationTapped?.call('chat:${data['conversationId']}');
        }
      }

      _isInitialized = true;
      debugPrint('[FCM] Firebase Cloud Messaging berhasil diinisialisasi.');
    } catch (e, stack) {
      debugPrint('[FCM] Gagal inisialisasi Firebase Cloud Messaging: $e\n$stack');
    }
  }

  /// Mengambil token FCM dan mengirimkannya ke backend
  static Future<void> syncTokenWithBackend(ApiClient apiClient) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        await sendTokenToBackend(apiClient, token);
      }
    } catch (e) {
      debugPrint('[FCM] Gagal mengambil FCM token: $e');
    }
  }

  /// Kirim token FCM ke backend API
  static Future<void> sendTokenToBackend(ApiClient apiClient, String fcmToken) async {
    try {
      await apiClient.post('/auth/fcm-token', data: {'token': fcmToken});
      debugPrint('[FCM] Token perangkat berhasil disinkronkan ke backend.');
    } catch (e) {
      debugPrint('[FCM] Gagal mengirim token ke backend: $e');
    }
  }

  /// Hapus token saat admin logout
  static Future<void> unregisterToken(ApiClient apiClient) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        await apiClient.delete('/auth/fcm-token');
      }
    } catch (e) {
      debugPrint('[FCM] Gagal menghapus token di backend: $e');
    }
  }
}
