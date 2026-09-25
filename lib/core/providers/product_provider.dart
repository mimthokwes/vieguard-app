import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  List<ProductModel> _products = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ProductModel> get products => _products;
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await ProductService.fetchProducts();
    _isLoading = false;

    if (response.success && response.data != null) {
      _products = response.data!;
    } else {
      _errorMessage = response.message;
    }
    notifyListeners();
  }

  Future<void> fetchCategories() async {
    final response = await ProductService.fetchCategories();
    if (response.success && response.data != null) {
      _categories = response.data!;
      notifyListeners();
    }
  }
}
