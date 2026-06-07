import 'package:flutter/material.dart';
import 'product.dart';

class OrderRequest {
  final int hotelId;
  final String deliveryAddress;
  final String customerPhone;
  final String? specialInstructions;
  final String paymentMethod;
  final List<OrderItemRequest> items;

  OrderRequest({
    required this.hotelId,
    required this.deliveryAddress,
    required this.customerPhone,
    this.specialInstructions,
    this.paymentMethod = 'telebirr',
    required this.items,
  });

  Map<String, dynamic> toJson() => {
        'hotel_id': hotelId,
        'delivery_address': deliveryAddress,
        'customer_phone': customerPhone,
        'special_instructions': specialInstructions,
        'payment_method': paymentMethod,
        'items': items.map((e) => e.toJson()).toList(),
      };
}

class OrderItemRequest {
  final int productId;
  final int quantity;

  OrderItemRequest({
    required this.productId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'quantity': quantity,
      };
}

class OrderResponse {
  final bool success;
  final OrderData? data; // ✅ Made nullable to avoid crash on empty response
  final String message;
  final String? orderNumber;
  final String? amount;
  final String? paymentUrl;

  OrderResponse({
    required this.success,
    this.data, // ✅ Now optional
    required this.message,
    this.orderNumber,
    this.amount,
    this.paymentUrl,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    // ✅ Removed print statements

    // Check if payment_url is at the top level
    if (json.containsKey('payment_url')) {
      return OrderResponse(
        success: json['success'] ?? false,
        data: json['data'] != null ? OrderData.fromJson(json['data']) : null,
        message: json['message'] ?? '',
        orderNumber: json['order_number'],
        amount: json['amount']?.toString(),
        paymentUrl: json['payment_url'],
      );
    }

    // Check if payment_url is nested inside data
    if (json['data'] != null && json['data']['payment_url'] != null) {
      return OrderResponse(
        success: json['success'] ?? false,
        data: OrderData.fromJson(json['data']),
        message: json['message'] ?? '',
        paymentUrl: json['data']['payment_url'],
        orderNumber: json['data']['order_number'],
        amount: json['data']['amount']?.toString(),
      );
    }

    // Regular order response
    return OrderResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? OrderData.fromJson(json['data']) : null,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'data': data?.toJson(), // ✅ Safe null-aware call
        'message': message,
        'order_number': orderNumber,
        'amount': amount,
        'payment_url': paymentUrl,
      };
}

// ✅ Kept PaymentResponse only if used elsewhere; add a toJson for completeness
class PaymentResponse {
  final bool success;
  final String orderNumber;
  final String amount;
  final String paymentUrl;

  PaymentResponse({
    required this.success,
    required this.orderNumber,
    required this.amount,
    required this.paymentUrl,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      success: json['success'] ?? false,
      orderNumber: json['order_number'] ?? '',
      amount: json['amount']?.toString() ?? '0',
      paymentUrl: json['payment_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'order_number': orderNumber,
        'amount': amount,
        'payment_url': paymentUrl,
      };
}

class OrderData {
  final int id;
  final String orderNumber;
  final int customerId;
  final int hotelId;
  final String status;
  final String paymentMethod;
  final String paymentStatus;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String deliveryAddress;
  final String customerPhone;
  final String? specialInstructions;
  final List<OrderItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;
  final dynamic hotel; // ✅ Consider replacing with a typed Hotel model later

  OrderData({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.hotelId,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.deliveryAddress,
    required this.customerPhone,
    this.specialInstructions,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
    this.hotel,
  });

  // ✅ Added empty constructor to avoid crashing on empty JSON
  factory OrderData.empty() => OrderData(
        id: 0,
        orderNumber: '',
        customerId: 0,
        hotelId: 0,
        status: 'pending',
        paymentMethod: 'cod',
        paymentStatus: 'pending',
        subtotal: 0.0,
        deliveryFee: 0.0,
        total: 0.0,
        deliveryAddress: '',
        customerPhone: '',
        items: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isPreparing => status.toLowerCase() == 'preparing';
  bool get isOut => status.toLowerCase() == 'out';
  bool get isDone => status.toLowerCase() == 'done';
  bool get isPaid => paymentStatus.toLowerCase() == 'paid';

  String get displayStatus {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Order Confirmed';
      case 'preparing':
        return 'Preparing Food';
      case 'out':
        return 'Out for Delivery';
      case 'done':
        return 'Delivered';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFF9800);
      case 'preparing':
        return const Color(0xFF2196F3);
      case 'out':
        return const Color(0xFFFF5722);
      case 'done':
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  factory OrderData.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return OrderData(
      id: json['id'] ?? 0,
      orderNumber: json['order_number'] ?? '',
      customerId: json['customer_id'] ?? 0,
      hotelId: json['hotel_id'] ?? 0,
      status: json['status'] ?? 'pending',
      paymentMethod: json['payment_method'] ?? 'cod',
      paymentStatus: json['payment_status'] ?? 'pending',
      subtotal: parseDouble(json['subtotal']),
      deliveryFee: parseDouble(json['delivery_fee']),
      total: parseDouble(json['total']),
      deliveryAddress: json['delivery_address'] ?? '',
      customerPhone: json['customer_phone'] ?? '',
      specialInstructions: json['special_instructions'],
      items: (json['items'] as List? ?? [])
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      hotel: json['hotel'],
    );
  }

  // ✅ Added missing toJson method
  Map<String, dynamic> toJson() => {
        'id': id,
        'order_number': orderNumber,
        'customer_id': customerId,
        'hotel_id': hotelId,
        'status': status,
        'payment_method': paymentMethod,
        'payment_status': paymentStatus,
        'subtotal': subtotal,
        'delivery_fee': deliveryFee,
        'total': total,
        'delivery_address': deliveryAddress,
        'customer_phone': customerPhone,
        'special_instructions': specialInstructions,
        'items': items.map((e) => e.toJson()).toList(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'hotel': hotel,
      };
}

class OrderItem {
  final int id;
  final int orderId;
  final int productId;
  final int quantity;
  final double price;
  final double total;
  final Product product;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.total,
    required this.product,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return OrderItem(
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      productId: json['product_id'] ?? 0,
      quantity: json['quantity'] ?? 0,
      price: parseDouble(json['price']),
      total: parseDouble(json['total']),
      product: Product.fromJson(json['product'] ?? {}),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'order_id': orderId,
        'product_id': productId,
        'quantity': quantity,
        'price': price,
        'total': total,
        'product': product.toJson(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
