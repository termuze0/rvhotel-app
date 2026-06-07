class Hotel {
  final int id;
  final String name;
  final String description;
  final String? image;
  final String address;
  final String phone;
  final String email;
  final double rating;
  final int reviewCount;
  final String cuisine;
  final int deliveryTime;
  final double deliveryFee;
  final double minOrderAmount;
  final bool isOpen;
  final double? latitude;
  final double? longitude;

  Hotel({
    required this.id,
    required this.name,
    required this.description,
    this.image,
    required this.address,
    required this.phone,
    required this.email,
    required this.rating,
    required this.reviewCount,
    required this.cuisine,
    required this.deliveryTime,
    required this.deliveryFee,
    required this.minOrderAmount,
    required this.isOpen,
    this.latitude,
    this.longitude,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      image: json['image'],
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      cuisine: json['cuisine'] ?? '',
      deliveryTime: json['delivery_time'] ?? 30,
      deliveryFee: (json['delivery_fee'] ?? 0).toDouble(),
      minOrderAmount: (json['min_order_amount'] ?? 0).toDouble(),
      isOpen: json['is_open'] ?? false,
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }
}
