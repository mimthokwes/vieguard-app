import 'package:flutter/foundation.dart';

import '../core/api/api_client.dart';
import '../core/api/api_exception.dart';
import '../core/storage/cache_storage.dart';
import '../models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  final ApiClient apiClient;
  NotificationProvider({required this.apiClient});

  List<AppNotification> _notifications = [];
  bool isLoading = false;
  String? errorMessage;
  DateTime? _lastFetched;

  bool get isFresh =>
      _lastFetched != null && DateTime.now().difference(_lastFetched!) < const Duration(minutes: 3);

  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Muat data dari penyimpanan lokal saat inisialisasi awal
  Future<void> initFromCache() async {
    final cached = await CacheStorage.load('notifications_list');
    if (cached != null && cached is List && _notifications.isEmpty) {
      try {
        _notifications = cached.map((e) => AppNotification.fromJson(e as Map<String, dynamic>)).toList();
        notifyListeners();
      } catch (e) {
        debugPrint('NotificationProvider.initFromCache error: $e');
      }
    }
  }

  Future<void> fetchNotifications({bool force = false}) async {
    if (!force && isFresh && _notifications.isNotEmpty) {
      return;
    }

    if (_notifications.isEmpty) {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
    }

    try {
      final data = await apiClient.get('/notifications');
      _notifications = (data as List<dynamic>).map((e) => AppNotification.fromJson(e as Map<String, dynamic>)).toList();
      _lastFetched = DateTime.now();
      CacheStorage.save('notifications_list', data);
    } on ApiException catch (e) {
      errorMessage = e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index == -1 || _notifications[index].isRead) return;
    try {
      await apiClient.patch('/notifications/$id/read');
      final old = _notifications[index];
      _notifications[index] = AppNotification(
        id: old.id,
        type: old.type,
        title: old.title,
        message: old.message,
        relatedOrderId: old.relatedOrderId,
        isRead: true,
        createdAt: old.createdAt,
      );
      notifyListeners();
      CacheStorage.save('notifications_list', _notifications.map((n) => n.toJson()).toList());
    } on ApiException catch (e) {
      errorMessage = e.message;
    }
  }

  Future<void> markAllAsRead() async {
    final unread = _notifications.where((n) => !n.isRead).toList();
    for (final n in unread) {
      await markAsRead(n.id);
    }
  }
}
