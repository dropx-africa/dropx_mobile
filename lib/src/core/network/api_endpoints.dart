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
  static const String requestOtp = '/auth/otp/request';
  static const String resendOtp = '/auth/otp/resend';
  static const String verifyOtp = '/auth/otp/verify';
  static const String refreshToken = '/auth/refresh';
  static const String profile = '/auth/profile';

  // Maps / Geocoding
  static const String geocode = '/maps/geocode';

  // Vendors
  static const String vendors = '/vendors';
  static String vendorById(String id) => '/vendors/$id';
  static String vendorMenu(String vendorId) => '/vendors/$vendorId/menu';
  static String storeCatalog(String vendorId) => '/stores/$vendorId/catalog';

  // Orders
  static const String orders = '/orders';
  static String orderById(String id) => '/orders/$id';
  static const String orderTracking = '/orders/tracking';

  // Cart
  static const String cart = '/cart';

  // Location
  static const String searchLocation = '/locations/search'; // legacy

  // Group Orders
  static const String groups = '/groups';
  static String groupById(String id) => '/groups/$id';
  static String groupPoll(String groupId) => '/groups/$groupId/poll';
}
