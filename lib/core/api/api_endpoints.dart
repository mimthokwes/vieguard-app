import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiEndpoints {
  // Base URL configuration (Default: http://localhost:5000 or Android Emulator 10.0.2.2)
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:5000';
    if (Platform.isAndroid) return 'http://10.0.2.2:5000';
    return 'http://localhost:5000';
  }

  // 1. Auth & Admin Account
  static String login = '/api/v0/mobile/auth/login';
  static String refresh = '/api/v0/mobile/auth/refresh';
  static String profile = '/api/v0/mobile/account/profile';

  // 2. Orders & Progress
  static String orders = '/api/v0/mobile/orders';
  static String orderDetail(String id) => '/api/v0/mobile/orders/$id';
  static String confirmOrder(String id) => '/api/v0/mobile/orders/$id/confirm';
  static String updateOrderProgress(String id) => '/api/v0/mobile/orders/$id/progress';

  // 3. Payments
  static String payments = '/api/v0/mobile/payments';
  static String verifyPayment(String id) => '/api/v0/mobile/payments/$id/verify';

  // 4. Rentals & Stock
  static String rentalCalendar = '/api/v0/mobile/rentals/calendar';
  static String updateRentalStatus(String id) => '/api/v0/mobile/rentals/$id/status';
  static String products = '/api/v0/mobile/products';
  static String productDetail(String id) => '/api/v0/mobile/products/$id';
  static String categories = '/api/v0/mobile/categories';
  static String accessories = '/api/v0/mobile/accessories';

  // 5. Chat
  static String chatConversations = '/api/v0/mobile/chat/conversations';
  static String chatMessages(String conversationId) => '/api/v0/mobile/chat/conversations/$conversationId';
  static String sendMessage(String conversationId) => '/api/v0/mobile/chat/conversations/$conversationId/messages';

  // 6. Notifications & Reports
  static String notifications = '/api/v0/mobile/notifications';
  static String reportSummary = '/api/v0/mobile/reports/summary';

  // 7. Store Profile & Admin Staff
  static String storeProfile = '/api/v0/mobile/store-profile';
  static String admins = '/api/v0/mobile/admins';
}
