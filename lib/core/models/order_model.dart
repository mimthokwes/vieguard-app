class OrderItemModel {
  final String id;
  final String itemName;
  final int quantity;
  final double unitPrice;
  final String? size;

  OrderItemModel({
    required this.id,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    this.size,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id']?.toString() ?? '',
      itemName: json['itemName'] ?? json['product']?['name'] ?? 'Item Seragam',
      quantity: json['quantity'] ?? 1,
      unitPrice: double.tryParse(json['unitPrice']?.toString() ?? '0') ?? 0.0,
      size: json['size'],
    );
  }
}

class OrderModel {
  final String id;
  final String orderNumber;
  final String orderType; // 'beli', 'sewa', 'custom'
  final String status; // 'pending', 'dikonfirmasi', 'diproses', 'siap_diambil', 'selesai', 'dibatalkan'
  final String customerName;
  final String schoolOrInstitution;
  final double totalPrice;
  final double dpAmount;
  final bool isLunas;
  final int progressPercentage;
  final String statusLabel;
  final String createdAt;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.orderType,
    required this.status,
    required this.customerName,
    required this.schoolOrInstitution,
    required this.totalPrice,
    required this.dpAmount,
    required this.isLunas,
    required this.progressPercentage,
    required this.statusLabel,
    required this.createdAt,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    var rawItems = json['orderItems'] as List? ?? json['items'] as List? ?? [];
    List<OrderItemModel> parsedItems = rawItems.map((i) => OrderItemModel.fromJson(i)).toList();

    return OrderModel(
      id: json['id']?.toString() ?? '',
      orderNumber: json['orderNumber'] ?? json['orderNo'] ?? '#VG-2024-000',
      orderType: json['orderType'] ?? 'beli',
      status: json['status'] ?? 'pending',
      customerName: json['user']?['name'] ?? json['customerName'] ?? 'Pelanggan VieGuard',
      schoolOrInstitution: json['schoolName'] ?? json['institution'] ?? 'Instansi / Sekolah',
      totalPrice: double.tryParse(json['totalPrice']?.toString() ?? '0') ?? 0.0,
      dpAmount: double.tryParse(json['dpAmount']?.toString() ?? '0') ?? 0.0,
      isLunas: json['isLunas'] ?? false,
      progressPercentage: json['progressPercentage'] ?? 0,
      statusLabel: json['statusLabel'] ?? 'Menunggu Konfirmasi',
      createdAt: json['createdAt'] ?? '',
      items: parsedItems,
    );
  }
}
