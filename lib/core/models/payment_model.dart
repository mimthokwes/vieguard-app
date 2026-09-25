class PaymentModel {
  final String id;
  final String orderId;
  final String orderNumber;
  final String customerName;
  final double amount;
  final String paymentType; // 'dp', 'pelunasan', 'refund'
  final String status; // 'menunggu', 'terverifikasi', 'ditolak'
  final String? proofUrl;
  final String? verifiedBy;
  final String? refundReason;
  final String createdAt;

  PaymentModel({
    required this.id,
    required this.orderId,
    required this.orderNumber,
    required this.customerName,
    required this.amount,
    required this.paymentType,
    required this.status,
    this.proofUrl,
    this.verifiedBy,
    this.refundReason,
    required this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id']?.toString() ?? '',
      orderId: json['orderId']?.toString() ?? '',
      orderNumber: json['order']?['orderNumber'] ?? json['orderNumber'] ?? '#VG-PAY-000',
      customerName: json['order']?['user']?['name'] ?? json['customerName'] ?? 'Pelanggan',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      paymentType: json['paymentType'] ?? 'dp',
      status: json['status'] ?? 'menunggu',
      proofUrl: json['proofUrl'] ?? json['proofImage'],
      verifiedBy: json['verifiedBy']?.toString(),
      refundReason: json['refundReason'],
      createdAt: json['createdAt'] ?? '',
    );
  }
}
