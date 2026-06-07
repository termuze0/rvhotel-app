import 'api_service.dart';
import '../config/api_config.dart';
import '../models/product.dart';

class ProductService {
  final ApiService _api = ApiService();

  // Get all products with pagination
  Future<ProductResponse> getProducts({
    int page = 1,
    int perPage = 15,
    String? category,
    String? search,
    int? hotelId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };

      if (category != null && category != 'All') {
        queryParams['category'] = category;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (hotelId != null) {
        queryParams['hotel_id'] = hotelId;
      }

      final response =
          await _api.get(ApiConfig.products, queryParams: queryParams);

      return ProductResponse.fromJson(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get single product details
  Future<Product> getProductDetails(int productId) async {
    try {
      final endpoint = ApiConfig.getUrl('/products/{$productId}');
      final response = await _api.get(endpoint);

      if (response['success'] == true && response['data'] != null) {
        return Product.fromJson(response['data']);
      }

      throw Exception('Product not found');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get products by hotel
  Future<ProductResponse> getProductsByHotel(int hotelId,
      {int page = 1}) async {
    return await getProducts(hotelId: hotelId, page: page);
  }

  // Get categories (extract unique categories from products or from API)
  Future<List<String>> getCategories() async {
    try {
      // First try to get categories from your API if you have an endpoint
      // For now, we'll fetch products and extract unique categories
      final response = await getProducts(perPage: 100);
      final categories =
          response.products.map((p) => p.category).toSet().toList();

      categories.sort();
      return ['All', ...categories];
    } catch (e) {
      // Return default categories if API fails
      return [
        'All',
        'Traditional',
        'Fast Food',
        'Italian',
        'Chinese',
        'Dessert'
      ];
    }
  }

  // Search products
  Future<ProductResponse> searchProducts(String query, {int page = 1}) async {
    return await getProducts(search: query, page: page);
  }

  String _handleError(dynamic error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'Failed to load products';
  }
}
