class RentalModel {
  final String id;
  final String orderId;
  final String customerName;
  final String customerPhone;
  final String costumeTitle;
  final String pickupDate;
  final String returnDate;
  final String status; // 'dipesan', 'diambil', 'dikembalikan', 'terlambat'
  final String? itemConditionBefore;
  final String? itemConditionAfter;
  final double penaltyAmount;
  final String? damageNote;

  RentalModel({
    required this.id,
    required this.orderId,
    required this.customerName,
    required this.customerPhone,
    required this.costumeTitle,
    required this.pickupDate,
    required this.returnDate,
    required this.status,
    this.itemConditionBefore,
    this.itemConditionAfter,
    this.penaltyAmount = 0.0,
    this.damageNote,
  });

  factory RentalModel.fromJson(Map<String, dynamic> json) {
    return RentalModel(
      id: json['id']?.toString() ?? '',
      orderId: json['orderId']?.toString() ?? '',
      customerName: json['order']?['user']?['name'] ?? json['customerName'] ?? 'Penyewa',
      customerPhone: json['order']?['user']?['phone'] ?? json['customerPhone'] ?? '08123456789',
      costumeTitle: json['costumeTitle'] ?? json['productName'] ?? 'Kostum Karnaval',
      pickupDate: json['pickupDate'] ?? '',
      returnDate: json['returnDate'] ?? '',
      status: json['status'] ?? 'dipesan',
      itemConditionBefore: json['itemConditionBefore'],
      itemConditionAfter: json['itemConditionAfter'],
      penaltyAmount: double.tryParse(json['penaltyAmount']?.toString() ?? '0') ?? 0.0,
      damageNote: json['damageNote'],
    );
  }
}
