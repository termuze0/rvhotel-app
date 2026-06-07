import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import '../../models/product.dart';
import '../../models/order.dart';
import '../../models/review.dart';

class ManagerService {
  final ApiService _api = ApiService();

  // ==================== PRODUCT MANAGEMENT ====================

  Future<List<Product>> getHotelProducts(int hotelId) async {
    try {
      final response = await _api.get(ApiConfig.hotelProducts);
      if (response['success'] == true) {
        if (response['data'] is List) {
          return (response['data'] as List)
              .map((json) => Product.fromJson(json))
              .toList();
        } else if (response['data']['data'] is List) {
          return (response['data']['data'] as List)
              .map((json) => Product.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Get hotel products error: $e');
      return [];
    }
  }

  Future<int?> addProductWithoutImage(Map<String, dynamic> productData) async {
    try {
      final response =
          await _api.post(ApiConfig.hotelAddProduct, data: productData);
      print('Add product without image response: $response');
      if (response['success'] == true && response['data'] != null) {
        return response['data']['id'];
      }
      return null;
    } catch (e) {
      print('Add product without image error: $e');
      return null;
    }
  }

  // Supports both File (Android) and Uint8List (Web)
  Future<bool> updateProductImage(
    int productId, {
    File? imageFile,
    Uint8List? imageBytes,
    String imageName = 'product_image.jpg',
  }) async {
    try {
      // Must have one or the other
      if (imageFile == null && imageBytes == null) return false;

      final token = await _api.getToken();
      if (token == null) {
        print('No auth token found');
        return false;
      }

      final endpoint = ApiConfig.getUrl(
        ApiConfig.hotelUpdateProduct,
        params: {'id': productId.toString()},
      );

      final uri = Uri.parse(endpoint);
      final request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
      request.fields['_method'] = 'PUT';

      if (kIsWeb && imageBytes != null) {
        // Web: use fromBytes
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: imageName,
          contentType: MediaType('image', _extensionFromName(imageName)),
        ));
      } else if (imageFile != null) {
        // Android/iOS: use fromPath
        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path),
        );
      }

      print('Sending image upload to: $endpoint');
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      print('Response status: ${response.statusCode}');
      print('Response body: $responseBody');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonResponse = json.decode(responseBody);
        return jsonResponse['success'] == true;
      }
      return false;
    } catch (e) {
      print('Update product image error: $e');
      return false;
    }
  }

  // Add product with image in one shot (legacy - also fixed for web)
  Future<bool> addProduct(
    Map<String, dynamic> productData, {
    File? imageFile,
    Uint8List? imageBytes,
    String imageName = 'product_image.jpg',
  }) async {
    try {
      final token = await _api.getToken();
      if (token == null) return false;

      final uri = Uri.parse(ApiConfig.hotelAddProduct);
      final request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      productData.forEach((key, value) {
        if (value != null) request.fields[key] = value.toString();
      });

      if (kIsWeb && imageBytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: imageName,
          contentType: MediaType('image', _extensionFromName(imageName)),
        ));
      } else if (imageFile != null && await imageFile.exists()) {
        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(responseBody);
        return jsonResponse['success'] == true;
      }
      return false;
    } catch (e) {
      print('Add product error: $e');
      return false;
    }
  }

  // Helper: extract image extension from filename
  String _extensionFromName(String name) {
    final ext = name.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':
        return 'png';
      case 'webp':
        return 'webp';
      case 'gif':
        return 'gif';
      default:
        return 'jpeg';
    }
  }

  Future<bool> updateProduct(
    int productId,
    Map<String, dynamic> productData, {
    File? imageFile,
    Uint8List? imageBytes,
    String imageName = 'product_image.jpg',
  }) async {
    try {
      final token = await _api.getToken();
      if (token == null) return false;

      final endpoint = ApiConfig.getUrl(
        ApiConfig.hotelUpdateProduct,
        params: {'id': productId.toString()},
      );

      print('UPDATE URL: $endpoint');

      final uri = Uri.parse(endpoint);
      final request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
      request.fields['_method'] = 'PUT';

      productData.forEach((key, value) {
        if (value != null && key != 'image') {
          if (value is bool) {
            request.fields[key] = value ? '1' : '0'; // ← bool fix
          } else {
            request.fields[key] = value.toString();
          }
        }
      });

      if (kIsWeb && imageBytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: imageName,
          contentType: MediaType('image', _extensionFromName(imageName)),
        ));
      } else if (imageFile != null && await imageFile.exists()) {
        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('UPDATE STATUS: ${response.statusCode}');
      print('UPDATE BODY: $responseBody');

      final jsonResponse = json.decode(responseBody);
      return response.statusCode == 200 && jsonResponse['success'] == true;
    } catch (e) {
      print('Update product error: $e');
      return false;
    }
  }

  Future<bool> deleteProduct(int productId) async {
    try {
      final token = await _api.getToken();
      if (token == null) return false;

      final endpoint = ApiConfig.getUrl(
        ApiConfig.hotelDeleteProduct,
        params: {'id': productId.toString()},
      );

      print('DELETE URL: $endpoint');

      final uri = Uri.parse(endpoint);
      final request = http.Request('DELETE', uri);
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();

      print('DELETE STATUS: ${streamedResponse.statusCode}');
      print('DELETE BODY: $responseBody');

      if (streamedResponse.statusCode == 200) {
        final jsonResponse = json.decode(responseBody);
        return jsonResponse['success'] == true;
      }
      return false;
    } catch (e) {
      print('Delete product error: $e');
      return false;
    }
  }

  Future<bool> toggleProductAvailability(int productId) async {
    try {
      final token = await _api.getToken();
      if (token == null) return false;

      final endpoint = ApiConfig.getUrl(
        ApiConfig.hotelToggleAvailability,
        params: {'id': productId.toString()},
      );

      final uri = Uri.parse(endpoint);
      final request = http.Request('PATCH', uri);
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
      request.headers['Content-Type'] = 'application/json';

      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();
      print('Toggle availability response: $responseBody');

      if (streamedResponse.statusCode >= 200 &&
          streamedResponse.statusCode < 300) {
        final jsonResponse = json.decode(responseBody);
        return jsonResponse['success'] == true;
      }
      return false;
    } catch (e) {
      print('Toggle availability error: $e');
      return false;
    }
  }

  // ==================== ORDER MANAGEMENT ====================

  Future<List<OrderData>> getHotelOrders(int hotelId) async {
    try {
      final response = await _api.get(ApiConfig.hotelOrders);

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> ordersData = response['data'];
        return ordersData.map((json) => OrderData.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Get hotel orders error: $e');
      return [];
    }
  }

  Future<bool> updateOrderStatus(int orderId, String status) async {
    try {
      final endpoint =
          ApiConfig.getUrl(ApiConfig.hotelUpdateOrderStatus, params: {
        'id': orderId.toString(),
      });
      final response = await _api.put(endpoint, data: {'status': status});
      return response['success'] ?? false;
    } catch (e) {
      print('Update order status error: $e');
      return false;
    }
  }

  // ==================== ANALYTICS ====================

  Future<ReviewSummary?> getReviews() async {
    try {
      final response = await _api.get(ApiConfig.hotelReviews);
      print('Reviews response: $response');
      if (response['reviews'] != null) {
        return ReviewSummary.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Get reviews error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> getAnalytics(int hotelId) async {
    try {
      final response = await _api.get(ApiConfig.hotelAnalytics);
      return response['success'] == true ? (response['data'] ?? {}) : {};
    } catch (e) {
      print('Get analytics error: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> getHotelInfo() async {
    try {
      final response = await _api.get(ApiConfig.hotelInfo);
      return response['success'] == true ? (response['data'] ?? {}) : {};
    } catch (e) {
      print('Get hotel info error: $e');
      return {};
    }
  }
}
