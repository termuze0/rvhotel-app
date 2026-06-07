class Review {
  final int id;
  final int productId;
  final int customerProfileId;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String customerName;
  final String customerEmail;

  Review({
    required this.id,
    required this.productId,
    required this.customerProfileId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
    required this.customerName,
    required this.customerEmail,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'] as Map<String, dynamic>?;
    final user = customer?['user'] as Map<String, dynamic>?;

    return Review(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      customerProfileId: json['customer_profile_id'] ?? 0,
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      customerName: user?['name'] ?? 'Customer ${json['customer_profile_id']}',
      customerEmail: user?['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'rating': rating,
        'comment': comment,
      };
}

class ReviewSummary {
  final List<Review> reviews;
  final double averageRating;
  final int totalReviews;

  ReviewSummary({
    required this.reviews,
    required this.averageRating,
    required this.totalReviews,
  });

  factory ReviewSummary.fromJson(Map<String, dynamic> json) {
    return ReviewSummary(
      reviews: (json['reviews'] as List? ?? [])
          .map((r) => Review.fromJson(r))
          .toList(),
      averageRating: (json['average_rating'] ?? 0).toDouble(),
      totalReviews: json['total_reviews'] ?? 0,
    );
  }
}
