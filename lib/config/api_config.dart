class ApiConfig {
  // ✅ Production Render - for everything except orders/payment
  static const String baseUrl = 'https://rvhotel-customer.onrender.com/api';
  static const String imageBaseUrl =
      'https://rvhotel-customer.onrender.com/storage';
  static const String storageUrl =
      'https://rvhotel-customer.onrender.com/storage';

  // ✅ Local ngrok - for orders/payment only (can reach Telebirr)
  // Replace with your ngrok URL each time you start ngrok
  static const String localBaseUrl =
      'https://elves-sprinkled-shortcut.ngrok-free.dev/api';

  // Auth Endpoints
  static const String login = '/login';
  static const String register = '/register';
  static const String logout = '/logout';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String userProfile = '/profile';
  static const String updateProfile = '/profile/update';

  static const String changePassword = '/change-password';

  // Products Endpoints
  static const String products = '/products';
  static const String productDetails = '/products/{id}';
  // Add this line with the other hotel endpoints
  static const String hotelToggleAvailability =
      '/hotel/products/{id}/toggle-availability';

  // Hotels Endpoints
  static const String hotels = '/hotels';
  static const String featuredHotels = '/featured-hotels';
  static const String hotelDetails = '/hotels/{id}';
  static const String hotelMenu = '/hotels/{id}/menu';

  // Food Items Endpoints
  static const String foodItems = '/food-items';
  static const String categories = '/categories';
  static const String searchFood = '/search-food';

  // Cart Endpoints
  static const String cart = '/cart';
  static const String addToCart = '/cart/add';
  static const String updateCartItem = '/cart/update/{id}';
  static const String removeFromCart = '/cart/remove/{id}';
  static const String clearCart = '/cart/clear';

  // Orders Endpoints — ✅ use localBaseUrl
  static const String createOrder = '/orders';
  static const String myOrders = '/orders/my';
  static const String orderDetails = '/orders/{id}';
  static const String trackOrder = '/orders/{id}/track';
  static const String cancelOrder = '/orders/{id}/cancel';
  static const String initiatePayment = '/orders/{id}/pay';

  static const String hotelProducts = '/hotel/products';
  static const String hotelProductDetails = '/hotel/products/{id}';
  static const String hotelAddProduct = '/hotel/products';
  static const String hotelUpdateProduct = '/hotel/products/{id}';
  static const String hotelDeleteProduct = '/hotel/products/{id}';

  static const String hotelOrders = '/hotel/orders';
  static const String hotelOrderDetails = '/hotel/orders/{id}';
  static const String hotelUpdateOrderStatus = '/hotel/orders/{id}/status';

  static const String hotelAnalytics = '/hotel/analytics';
  static const String hotelStats = '/hotel/dashboard/stats';
  static const String hotelProfile = '/hotel/profile';
  static const String hotelInfo = '/hotel/info';
  static const String hotelReviews = '/hotel/reviews';
  static String getUrl(String endpoint, {Map<String, String>? params}) {
    var url = baseUrl + endpoint;
    if (params != null) {
      params.forEach((key, value) {
        url = url.replaceAll('{$key}', value);
      });
    }
    return url;
  }

  // ✅ Use this for order/payment endpoints
  static String getLocalUrl(String endpoint, {Map<String, String>? params}) {
    var url = localBaseUrl + endpoint;
    if (params != null) {
      params.forEach((key, value) {
        url = url.replaceAll('{$key}', value);
      });
    }
    return url;
  }
}
