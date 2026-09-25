import 'package:flutter/material.dart';
import '../models/rental_model.dart';
import '../services/rental_service.dart';

class RentalProvider extends ChangeNotifier {
  List<RentalModel> _rentals = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<RentalModel> get rentals => _rentals;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchCalendar({String? startDate, String? endDate}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await RentalService.fetchCalendar(startDate: startDate, endDate: endDate);
    _isLoading = false;

    if (response.success && response.data != null) {
      _rentals = response.data!;
    } else {
      _errorMessage = response.message;
    }
    notifyListeners();
  }

  Future<bool> updateStatus({
    required String id,
    required String status,
    String? itemConditionBefore,
    String? itemConditionAfter,
    double penaltyAmount = 0.0,
    String? damageNote,
  }) async {
    final response = await RentalService.updateStatus(
      id: id,
      status: status,
      itemConditionBefore: itemConditionBefore,
      itemConditionAfter: itemConditionAfter,
      penaltyAmount: penaltyAmount,
      damageNote: damageNote,
    );
    if (response.success) {
      await fetchCalendar();
      return true;
    }
    return false;
  }
}
