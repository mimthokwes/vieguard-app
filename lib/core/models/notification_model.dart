class NotificationModel {
  final String id;
  final String type; // 'ORDER_NEW', 'PAYMENT_VERIFIED', 'RENTAL_RETURN', etc.
  final String title;
  final String message;
  final String? relatedOrderId;
  final bool isRead;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.relatedOrderId,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? 'GENERAL',
      title: json['title'] ?? 'Notifikasi System',
      message: json['message'] ?? '',
      relatedOrderId: json['relatedOrderId']?.toString(),
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] ?? '',
    );
  }
}
