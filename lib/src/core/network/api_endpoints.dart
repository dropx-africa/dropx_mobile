/// Centralized API endpoint paths.
///
/// All endpoint strings live here so they can be updated in one place
/// when the backend changes.
library;

class ApiEndpoints {
  ApiEndpoints._();

  // Base
  static const String baseUrl = 'https://api-production-dcbb.up.railway.app';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String verifyOtp = '/auth/verify-otp';
  static const String refreshToken = '/auth/refresh';
  static const String profile = '/auth/profile';

  // Google
  static const String googlePlacesAutocomplete =
      'https://maps.googleapis.com/maps/api/place/autocomplete/json';

  // Vendors
  static const String vendors = '/vendors';
  static String vendorById(String id) => '/vendors/$id';
  static String vendorMenu(String vendorId) => '/vendors/$vendorId/menu';

  // Orders
  static const String orders = '/orders';
  static String orderById(String id) => '/orders/$id';
  static const String orderTracking = '/orders/tracking';

  // Cart
  static const String cart = '/cart';

  // Location
  static const String searchLocation = '/locations/search';

  // Group Orders
  static const String groups = '/groups';
  static String groupById(String id) => '/groups/$id';
  static String groupPoll(String groupId) => '/groups/$groupId/poll';
}
