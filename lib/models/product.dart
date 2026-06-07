import 'package:flutter/material.dart';
import '../config/api_config.dart';

class Product {
  final int id;
  final int hotelId;
  final String name;
  final String description;
  final double price;
  final String category;
  final int preparationTime;
  final bool isAvailable;
  final bool isFeatured;
  final String? ingredients;
  final int? calories;
  final String? image;
  final String? imageUrl;
  final double averageRating;
  final int reviewCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final HotelInfo? hotel;

  Product({
    required this.id,
    required this.hotelId,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.preparationTime,
    required this.isAvailable,
    required this.isFeatured,
    this.ingredients,
    this.calories,
    this.image,
    this.imageUrl,
    required this.averageRating,
    this.reviewCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.hotel,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    DateTime parseDateTime(String? value) {
      if (value == null || value.isEmpty) return DateTime.now();
      return DateTime.tryParse(value) ?? DateTime.now();
    }

    return Product(
      id: json['id'] ?? 0,
      hotelId: json['hotel_id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: parseDouble(json['price']),
      category: json['category'] ?? 'General',
      preparationTime: parseInt(json['preparation_time']),
      isAvailable: json['is_available'] ?? false,
      isFeatured: json['is_featured'] ?? false,
      ingredients: json['ingredients'],
      calories: json['calories'] != null ? parseInt(json['calories']) : null,
      image: json['image'],
      imageUrl: json['image_url'],
      averageRating: parseDouble(json['average_rating']),
      reviewCount: parseInt(json['review_count']),
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
      hotel: json['hotel'] != null ? HotelInfo.fromJson(json['hotel']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'hotel_id': hotelId,
        'name': name,
        'description': description,
        'price': price,
        'category': category,
        'preparation_time': preparationTime,
        'is_available': isAvailable,
        'is_featured': isFeatured,
        'ingredients': ingredients,
        'calories': calories,
        'image': image,
        'image_url': imageUrl,
        'average_rating': averageRating,
        'review_count': reviewCount,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'hotel': hotel?.toJson(),
      };

// Helper method to get full image URL - COMPLETELY FIXED
  String get imageFullUrl {
    // FIRST: Check image field (this contains Cloudinary URL for product 19)
    if (image != null && image!.isNotEmpty) {
      // If it's a Cloudinary URL (starts with https://res.cloudinary.com)
      if (image!.contains('cloudinary.com') ||
          image!.startsWith('https://res.cloudinary.com')) {
        print('Using Cloudinary image directly: $image');
        return image!;
      }
      // If it's already a full URL (starts with http)
      if (image!.startsWith('http')) {
        print('Using full URL from image field: $image');
        return image!;
      }
      // For local storage paths like "products/xxx.jpg"
      // Use the storage URL without /api prefix
      print('Building local storage URL for: $image');
      return '${ApiConfig.storageUrl}/$image';
    }

    // SECOND: Check image_url field
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      // Skip malformed URLs that have localhost + cloudinary mix
      if (imageUrl!.contains('127.0.0.1') && imageUrl!.contains('cloudinary')) {
        // Try to get the Cloudinary URL from image field instead
        if (image != null && image!.contains('cloudinary.com')) {
          return image!;
        }
        // Extract Cloudinary URL using regex
        final cloudinaryMatch = RegExp(r'https://res\.cloudinary\.com/[^\s"]+')
            .firstMatch(imageUrl!);
        if (cloudinaryMatch != null) {
          print('Extracted Cloudinary URL: ${cloudinaryMatch.group(0)}');
          return cloudinaryMatch.group(0)!;
        }
      }

      // Fix: Remove /api from storage URLs
      var cleanUrl = imageUrl!;
      if (cleanUrl.contains('/api/storage/')) {
        cleanUrl = cleanUrl.replaceFirst('/api/storage/', '/storage/');
        print('Cleaned URL (removed /api): $cleanUrl');
      }

      return cleanUrl;
    }

    print('No image available for product: ${name}');
    return '';
  }

  // Helper method to check if product has image
  bool get hasImage {
    return imageFullUrl.isNotEmpty;
  }

  // Helper method to check if image is from Cloudinary
  bool get isCloudinaryImage {
    return imageFullUrl.contains('cloudinary.com');
  }

  // Helper method to get Cloudinary optimized URL with transformations
  String getCloudinaryUrl({int width = 300, int height = 300}) {
    if (!isCloudinaryImage) return imageFullUrl;

    // Add Cloudinary transformations for better performance
    final baseUrl = imageFullUrl;
    final uri = Uri.parse(baseUrl);
    final path = uri.path;

    // Insert transformations before the upload path
    return '${uri.scheme}://${uri.host}/c_limit,w_$width,h_$height/$path';
  }

  // Helper method to get formatted price
  String get formattedPrice => 'ETB ${price.toStringAsFixed(2)}';

  // Helper method to get formatted average rating
  String get formattedAverageRating => averageRating.toStringAsFixed(1);

  // Helper method to get star rating display
  List<Widget> getStarRating({double size = 12}) {
    List<Widget> stars = [];
    int fullStars = averageRating.floor();
    bool hasHalfStar = (averageRating - fullStars) >= 0.5;

    for (int i = 0; i < fullStars; i++) {
      stars.add(Icon(Icons.star, size: size, color: Colors.amber));
    }

    if (hasHalfStar) {
      stars.add(Icon(Icons.star_half, size: size, color: Colors.amber));
    }

    int remainingStars = 5 - stars.length;
    for (int i = 0; i < remainingStars; i++) {
      stars.add(Icon(Icons.star_border, size: size, color: Colors.amber));
    }

    return stars;
  }
}

class HotelInfo {
  final int id;
  final int userId;
  final String hotelName;
  final String? description;
  final String address;
  final double? lat;
  final double? long;
  final String opensAt;
  final String closesAt;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;

  HotelInfo({
    required this.id,
    required this.userId,
    required this.hotelName,
    this.description,
    required this.address,
    this.lat,
    this.long,
    required this.opensAt,
    required this.closesAt,
    required this.isAvailable,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HotelInfo.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    DateTime parseDateTime(String? value) {
      if (value == null || value.isEmpty) return DateTime.now();
      return DateTime.tryParse(value) ?? DateTime.now();
    }

    return HotelInfo(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      hotelName: json['hotel_name'] ?? '',
      description: json['description'],
      address: json['address'] ?? '',
      lat: parseDouble(json['lat']),
      long: parseDouble(json['long']),
      opensAt: json['opens_at'] ?? '00:00:00',
      closesAt: json['closes_at'] ?? '00:00:00',
      isAvailable: json['is_available'] ?? false,
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'hotel_name': hotelName,
        'description': description,
        'address': address,
        'lat': lat,
        'long': long,
        'opens_at': opensAt,
        'closes_at': closesAt,
        'is_available': isAvailable,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  bool get isOpenNow {
    final now = DateTime.now();
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:00';
    return currentTime.compareTo(opensAt) >= 0 &&
        currentTime.compareTo(closesAt) <= 0;
  }

  String get formattedHours => '$opensAt - $closesAt';
}

// Product Response for paginated API response
class ProductResponse {
  final bool success;
  final List<Product> products;
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;
  final String? nextPageUrl;
  final String? prevPageUrl;
  final String message;

  ProductResponse({
    required this.success,
    required this.products,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
    this.nextPageUrl,
    this.prevPageUrl,
    required this.message,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return ProductResponse(
      success: json['success'] ?? false,
      products: (data['data'] as List)
          .map((productJson) => Product.fromJson(productJson))
          .toList(),
      currentPage: data['current_page'] ?? 1,
      lastPage: data['last_page'] ?? 1,
      total: data['total'] ?? 0,
      perPage: data['per_page'] ?? 15,
      nextPageUrl: data['next_page_url'],
      prevPageUrl: data['prev_page_url'],
      message: json['message'] ?? '',
    );
  }

  bool get hasMore => nextPageUrl != null;
}
