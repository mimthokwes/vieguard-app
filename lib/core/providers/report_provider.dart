import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../services/report_service.dart';

class ReportProvider extends ChangeNotifier {
  ReportSummaryModel? _summary;
  bool _isLoading = false;
  String? _errorMessage;

  ReportSummaryModel? get summary => _summary;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchSummary({String? startDate, String? endDate}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await ReportService.fetchSummary(startDate: startDate, endDate: endDate);
    _isLoading = false;

    if (response.success && response.data != null) {
      _summary = response.data;
    } else {
      _errorMessage = response.message;
    }
    notifyListeners();
  }
}
