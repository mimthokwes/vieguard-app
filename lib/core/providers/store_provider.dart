import 'package:flutter/material.dart';
import '../models/store_profile_model.dart';
import '../models/admin_model.dart';
import '../services/store_service.dart';

class StoreProvider extends ChangeNotifier {
  StoreProfileModel? _profile;
  List<AdminModel> _staffList = [];
  bool _isLoading = false;
  String? _errorMessage;

  StoreProfileModel? get profile => _profile;
  List<AdminModel> get staffList => _staffList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await StoreService.fetchStoreProfile();
    _isLoading = false;

    if (response.success && response.data != null) {
      _profile = response.data;
    } else {
      _errorMessage = response.message;
    }
    notifyListeners();
  }

  Future<bool> updateProfile(StoreProfileModel newProfile) async {
    final response = await StoreService.updateStoreProfile(newProfile);
    if (response.success && response.data != null) {
      _profile = response.data;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> fetchStaffList() async {
    final response = await StoreService.fetchStaffList();
    if (response.success && response.data != null) {
      _staffList = response.data!;
      notifyListeners();
    }
  }
}
