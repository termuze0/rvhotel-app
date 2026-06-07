import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();

  List<Product> _products = [];
  List<String> _categories = [];

  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  int _totalProducts = 0;

  String? _error;
  String? _selectedCategory;
  String? _searchQuery;

  List<Product> get products => _products;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get error => _error;
  String? get selectedCategory => _selectedCategory;
  int get totalProducts => _totalProducts;

  Future<void> loadProducts({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _products.clear();
      _hasMore = true;
    }

    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _productService.getProducts(
        page: _currentPage,
        category: _selectedCategory,
        search: _searchQuery,
      );

      if (refresh) {
        _products = List<Product>.from(response.products);
      } else {
        _products.addAll(response.products);
      }

      _totalProducts = response.total;
      _hasMore = response.nextPageUrl != null;

      if (_hasMore) {
        _currentPage++;
      }

      debugPrint(
          'Loaded ${response.products.length} products. Total: ${_products.length}');

      for (final product in response.products) {
        debugPrint('Product: ${product.name}');
        debugPrint('Image URL: ${product.imageUrl}');
        debugPrint('Full URL: ${product.imageFullUrl}');
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Product loading error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCategories() async {
    try {
      _categories = await _productService.getCategories();
    } catch (e) {
      _categories = [
        'All',
        'Traditional',
        'Fast Food',
        'Italian',
        'Chinese',
        'Dessert',
      ];
    }

    notifyListeners();
  }

  void filterByCategory(String? category) {
    _selectedCategory = category == 'All' ? null : category;
    loadProducts(refresh: true);
  }

  void searchProducts(String query) {
    _searchQuery = query.trim().isEmpty ? null : query.trim();
    loadProducts(refresh: true);
  }

  void clearSearch() {
    _searchQuery = null;
    loadProducts(refresh: true);
  }

  Product? getProductById(int id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (_) {
      return null;
    }
  }

  void clearProducts() {
    _products.clear();
    _currentPage = 1;
    _hasMore = true;
    notifyListeners();
  }

  void debugPrintProducts() {
    for (final product in _products) {
      debugPrint('Product: ${product.name}');
      debugPrint('Image URL: ${product.imageUrl}');
      debugPrint('Has Image: ${product.hasImage}');
      debugPrint('Full URL: ${product.imageFullUrl}');
      debugPrint('--------------------');
    }
  }
}
