import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/order.dart';
import '../services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();

  List<OrderData> _orders = [];
  OrderData? _currentOrder;
  bool _isLoading = false;
  String? _error;
  bool _isPlacingOrder = false;
  String? _paymentUrl;

  List<OrderData> get orders => _orders;
  OrderData? get currentOrder => _currentOrder;
  bool get isLoading => _isLoading;
  bool get isPlacingOrder => _isPlacingOrder;
  String? get error => _error;
  String? get paymentUrl => _paymentUrl;
  bool get hasPaymentUrl => _paymentUrl != null && _paymentUrl!.isNotEmpty;

  Future<bool> placeOrder({
    required int hotelId,
    required String deliveryAddress,
    required String customerPhone,
    String? specialInstructions,
    required List<OrderItemRequest> items,
    String paymentMethod = 'telebirr',
  }) async {
    _isPlacingOrder = true;
    _error = null;
    _paymentUrl = null;
    notifyListeners();

    try {
      final request = OrderRequest(
        hotelId: hotelId,
        deliveryAddress: deliveryAddress,
        customerPhone: customerPhone,
        specialInstructions: specialInstructions,
        paymentMethod: paymentMethod, // ✅ Uses selected method
        items: items,
      );

      final response = await _orderService.createOrder(request);

      if (response.success) {
        _currentOrder = response.data; // ✅ nullable now, safe

        if (response.paymentUrl != null && response.paymentUrl!.isNotEmpty) {
          _paymentUrl = response.paymentUrl;
        }

        _isPlacingOrder = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        _isPlacingOrder = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isPlacingOrder = false;
      notifyListeners();
      return false;
    }
  }

  // ✅ Opens Telebirr payment URL in external browser/app
  Future<bool> launchPayment() async {
    if (!hasPaymentUrl) {
      _error = 'No payment URL available';
      notifyListeners();
      return false;
    }

    try {
      final uri = Uri.parse(_paymentUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        return true;
      } else {
        _error = 'Could not open payment page';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Failed to open payment: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<String?> initiatePayment(int orderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // ✅ Now correctly uses PaymentResponse
      final response = await _orderService.initiatePayment(orderId);
      _isLoading = false;

      if (response.success && response.paymentUrl.isNotEmpty) {
        _paymentUrl = response.paymentUrl; // ✅ Save URL
        notifyListeners();
        return response.paymentUrl;
      }

      _error = 'Payment URL not returned from server';
      notifyListeners();
      return null;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> loadMyOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await _orderService.getMyOrders();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<OrderData?> getOrderDetails(int orderId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final order = await _orderService.getOrderDetails(orderId);
      _isLoading = false;
      notifyListeners();
      return order;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> cancelOrder(int orderId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _orderService.cancelOrder(orderId);
      if (success) await loadMyOrders();
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    _orders = [];
    _currentOrder = null;
    _error = null;
    _isLoading = false;
    _isPlacingOrder = false;
    _paymentUrl = null;
    notifyListeners();
  }
}
