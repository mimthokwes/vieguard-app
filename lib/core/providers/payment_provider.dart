import 'package:flutter/material.dart';
import '../models/payment_model.dart';
import '../services/payment_service.dart';

class PaymentProvider extends ChangeNotifier {
  List<PaymentModel> _payments = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<PaymentModel> get payments => _payments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchPayments({String? status}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await PaymentService.fetchPayments(status: status);
    _isLoading = false;

    if (response.success && response.data != null) {
      _payments = response.data!;
    } else {
      _errorMessage = response.message;
    }
    notifyListeners();
  }

  Future<bool> verifyPayment(String id, String status, {String? refundReason}) async {
    final response = await PaymentService.verifyPayment(id: id, status: status, refundReason: refundReason);
    if (response.success) {
      await fetchPayments();
      return true;
    }
    return false;
  }
}
