import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchOrders({String? status, String? orderType}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await OrderService.fetchOrders(status: status, orderType: orderType);
    _isLoading = false;

    if (response.success && response.data != null) {
      _orders = response.data!;
    } else {
      _errorMessage = response.message;
    }
    notifyListeners();
  }

  Future<bool> confirmOrder(String id, double dpAmount) async {
    final response = await OrderService.confirmOrder(id: id, dpAmount: dpAmount);
    if (response.success) {
      await fetchOrders();
      return true;
    }
    return false;
  }

  Future<bool> updateProgress(String id, int percentage, String label, {String? note}) async {
    final response = await OrderService.updateProgress(
      id: id,
      progressPercentage: percentage,
      statusLabel: label,
      note: note,
    );
    if (response.success) {
      await fetchOrders();
      return true;
    }
    return false;
  }
}
