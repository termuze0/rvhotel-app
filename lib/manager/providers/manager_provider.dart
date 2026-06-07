import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/manager_service.dart';
import '../../models/product.dart';
import '../../models/order.dart';
import '../../models/review.dart';

class ManagerProvider extends ChangeNotifier {
  final ManagerService _service = ManagerService();

  List<OrderData> _orders = [];
  List<Product> _products = [];
  ReviewSummary? _reviewSummary;
  bool _isLoading = false;
  String? _error;
  int _selectedHotelId = 1;
  Map<String, dynamic> _dashboardStats = {};
  Map<String, dynamic> _hotelInfo = {};

  List<OrderData> get orders => _orders;
  List<Product> get products => _products;
  ReviewSummary? get reviewSummary => _reviewSummary;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get selectedHotelId => _selectedHotelId;
  Map<String, dynamic> get dashboardStats => _dashboardStats;
  Map<String, dynamic> get hotelInfo => _hotelInfo;

  int get pendingOrdersCount =>
      _orders.where((o) => o.status == 'pending').length;
  int get preparingOrdersCount =>
      _orders.where((o) => o.status == 'preparing').length;
  int get outForDeliveryCount => _orders.where((o) => o.status == 'out').length;
  int get completedOrdersCount =>
      _orders.where((o) => o.status == 'done').length;
  int get totalProducts => _products.length;
  double get totalRevenue => _orders
      .where((o) => o.status == 'done')
      .fold(0.0, (sum, order) => sum + order.total);

  Future<void> loadProducts() async {
    _setLoading(true);
    try {
      _products = await _service.getHotelProducts(_selectedHotelId);
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  Future<void> loadReviews() async {
    _setLoading(true);
    try {
      _reviewSummary = await _service.getReviews();
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  Future<bool> addProductWithImage(
    Map<String, dynamic> productData, {
    File? imageFile,
    Uint8List? imageBytes,
    String imageName = 'product_image.jpg',
  }) async {
    _setLoading(true);
    try {
      final productId = await _service.addProductWithoutImage(productData);
      if (productId == null) {
        _setLoading(false);
        return false;
      }
      if (imageFile != null || imageBytes != null) {
        await _service.updateProductImage(
          productId,
          imageFile: imageFile,
          imageBytes: imageBytes,
          imageName: imageName,
        );
      }
      await loadProducts();
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> addProduct(
    Map<String, dynamic> productData, {
    File? imageFile,
    Uint8List? imageBytes,
    String imageName = 'product_image.jpg',
  }) async {
    _setLoading(true);
    try {
      final data = Map<String, dynamic>.from(productData);
      data.remove('hotel_id');
      final success = await _service.addProduct(
        data,
        imageFile: imageFile,
        imageBytes: imageBytes,
        imageName: imageName,
      );
      if (success) await loadProducts();
      _setLoading(false);
      return success;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateProductImage(
    int productId, {
    File? imageFile,
    Uint8List? imageBytes,
    String imageName = 'product_image.jpg',
  }) async {
    _setLoading(true);
    try {
      final success = await _service.updateProductImage(
        productId,
        imageFile: imageFile,
        imageBytes: imageBytes,
        imageName: imageName,
      );
      if (success) await loadProducts();
      _setLoading(false);
      return success;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateProduct(
    int productId,
    Map<String, dynamic> productData, {
    File? imageFile,
    Uint8List? imageBytes,
    String imageName = 'product_image.jpg',
  }) async {
    _setLoading(true);
    try {
      final success = await _service.updateProduct(
        productId,
        productData,
        imageFile: imageFile,
        imageBytes: imageBytes,
        imageName: imageName,
      );
      if (success) await loadProducts();
      _setLoading(false);
      return success;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteProduct(int productId) async {
    _setLoading(true);
    try {
      final success = await _service.deleteProduct(productId);
      if (success) await loadProducts();
      _setLoading(false);
      return success;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> toggleProductAvailability(int productId) async {
    _setLoading(true);
    try {
      final success = await _service.toggleProductAvailability(productId);
      if (success) await loadProducts();
      _setLoading(false);
      return success;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<void> loadOrders() async {
    _setLoading(true);
    try {
      _orders = await _service.getHotelOrders(_selectedHotelId);
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  Future<bool> updateOrderStatus(int orderId, String status) async {
    _setLoading(true);
    try {
      final success = await _service.updateOrderStatus(orderId, status);
      if (success) await loadOrders();
      _setLoading(false);
      return success;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<void> loadHotelInfo() async {
    try {
      _hotelInfo = await _service.getHotelInfo();
      notifyListeners();
    } catch (e) {
      print('Load hotel info error: $e');
    }
  }

  void setHotelId(int hotelId) {
    _selectedHotelId = hotelId;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    _orders = [];
    _products = [];
    _reviewSummary = null;
    _dashboardStats = {};
    _hotelInfo = {};
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
