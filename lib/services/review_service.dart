import 'api_service.dart';
import '../config/api_config.dart';
import '../models/review.dart';

class ReviewService {
  final ApiService _api = ApiService();

  Future<ReviewSummary> getProductReviewsWithSummary(int productId) async {
    try {
      final endpoint = '/products/$productId/reviews';
      print('Fetching reviews from: $endpoint');

      final response = await _api.get(endpoint);
      print('Reviews API response: $response');

      return ReviewSummary.fromJson(response);
    } catch (e) {
      print('Get reviews error: $e');
      return ReviewSummary(
        reviews: [],
        averageRating: 0,
        totalReviews: 0,
      );
    }
  }

  // For backward compatibility
  Future<List<Review>> getProductReviews(int productId) async {
    final summary = await getProductReviewsWithSummary(productId);
    return summary.reviews;
  }

  // POST /reviews
  Future<Map<String, dynamic>> addReview({
    required int productId,
    required int rating,
    required String comment,
    required int customerProfileId,
  }) async {
    try {
      final response = await _api.post('/reviews', data: {
        'product_id': productId,
        'rating': rating,
        'comment': comment,
      });

      print('Review response: $response'); // Debug log

      return {
        'success': true,
        'message': response['message'] ?? 'Review saved successfully',
        'review': response['review'] != null
            ? Review.fromJson(response['review'])
            : null,
      };
    } catch (e) {
      print('Add review error: $e');
      return {
        'success': false,
        'message': e.toString(),
        'review': null,
      };
    }
  }

  // GET /reviews/{review}
  Future<Review?> getReview(int reviewId) async {
    try {
      final response = await _api.get('/reviews/$reviewId');

      if (response['success'] == true && response['data'] != null) {
        return Review.fromJson(response['data']);
      } else if (response['review'] != null) {
        return Review.fromJson(response['review']);
      }

      return null;
    } catch (e) {
      print('Get review error: $e');
      return null;
    }
  }

  // Get average rating for a product
  Future<double> getAverageRating(int productId) async {
    try {
      final reviews = await getProductReviews(productId);
      if (reviews.isEmpty) return 0.0;

      final total = reviews.fold(0, (sum, review) => sum + review.rating);
      return total / reviews.length;
    } catch (e) {
      return 0.0;
    }
  }

  // Get total reviews count
  Future<int> getTotalReviewsCount(int productId) async {
    try {
      final reviews = await getProductReviews(productId);
      return reviews.length;
    } catch (e) {
      return 0;
    }
  }
}
