class ReportSummaryModel {
  final double totalRevenue;
  final int totalOrders;
  final int completedRentals;
  final int activeRentals;

  ReportSummaryModel({
    required this.totalRevenue,
    required this.totalOrders,
    required this.completedRentals,
    required this.activeRentals,
  });

  factory ReportSummaryModel.fromJson(Map<String, dynamic> json) {
    return ReportSummaryModel(
      totalRevenue: double.tryParse(json['totalRevenue']?.toString() ?? '0') ?? 0.0,
      totalOrders: json['totalOrders'] ?? 0,
      completedRentals: json['completedRentals'] ?? 0,
      activeRentals: json['activeRentals'] ?? 0,
    );
  }
}
