import 'package:flutter/material.dart';
import '../models/admin_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AdminModel? _currentAdmin;
  bool _isLoading = false;
  String? _errorMessage;

  AdminModel? get currentAdmin => _currentAdmin;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await AuthService.login(email: email, password: password);
    _isLoading = false;

    if (response.success && response.data != null) {
      _currentAdmin = response.data;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadProfile() async {
    final response = await AuthService.fetchProfile();
    if (response.success && response.data != null) {
      _currentAdmin = response.data;
      notifyListeners();
    }
  }
}
