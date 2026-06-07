import 'api_service.dart';
import '../config/api_config.dart';
import '../models/order.dart';

class OrderService {
  final ApiService _api = ApiService();

  // CREATE ORDER - POST request
  Future<OrderResponse> createOrder(OrderRequest request) async {
    try {
      print('Creating order with data: ${request.toJson()}');
      final response =
          await _api.post(ApiConfig.createOrder, data: request.toJson());
      print('RAW ORDER RESPONSE: $response'); // ← add this
      return OrderResponse.fromJson(response);
    } catch (e) {
      print('Order creation error: $e');
      throw _handleError(e);
    }
  }

  // INITIATE TELEBIRR PAYMENT

  Future<PaymentResponse> initiatePayment(int orderId) async {
    try {
      final endpoint = ApiConfig.initiatePayment.replaceAll('{id}', '$orderId');
      print('Initiating payment at: $endpoint');
      print('Using base URL: ${ApiConfig.localBaseUrl}'); // ✅ add this
      final response = await _api.post(
        endpoint,
        baseUrl: ApiConfig.localBaseUrl,
      );
      print('RAW PAYMENT RESPONSE: $response');
      return PaymentResponse.fromJson(response);
    } catch (e) {
      print('Payment initiation error: $e');
      throw _handleError(e);
    }
  }

  // GET USER ORDERS - GET request
  Future<List<OrderData>> getMyOrders() async {
    try {
      print('Fetching orders from: ${ApiConfig.myOrders}');
      final response = await _api.get(ApiConfig.myOrders);

      if (response['success'] == true) {
        if (response['data'] is List) {
          return (response['data'] as List)
              .map((json) => OrderData.fromJson(json))
              .toList();
        } else if (response['data']['data'] is List) {
          return (response['data']['data'] as List)
              .map((json) => OrderData.fromJson(json))
              .toList();
        }
      }

      return [];
    } catch (e) {
      print('Get orders error: $e');
      throw _handleError(e);
    }
  }

  // GET SINGLE ORDER DETAILS
  Future<OrderData> getOrderDetails(int orderId) async {
    try {
      final endpoint = '/orders/$orderId';
      print('Fetching order details from: $endpoint');
      final response = await _api.get(endpoint);
      if (response['success'] == true && response['data'] != null) {
        return OrderData.fromJson(response['data']);
      }
      throw Exception('Order not found');
    } catch (e) {
      print('Get order details error: $e');
      throw _handleError(e);
    }
  }

  // TRACK ORDER
  Future<Map<String, dynamic>> trackOrder(int orderId) async {
    try {
      final endpoint = '/orders/$orderId/track';
      final response = await _api.get(endpoint);
      return response['data'] ?? {};
    } catch (e) {
      throw _handleError(e);
    }
  }

  // CANCEL ORDER
  Future<bool> cancelOrder(int orderId) async {
    try {
      final endpoint = '/orders/$orderId/cancel';
      final response = await _api.post(endpoint);
      return response['success'] ?? false;
    } catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(dynamic error) {
    if (error is ApiException) {
      print('API Exception: ${error.message}, Status: ${error.statusCode}');
      return error.message;
    }
    print('Unknown error: $error');
    return 'Failed to process order';
  }
}
