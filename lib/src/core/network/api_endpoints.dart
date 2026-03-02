/// Centralized API endpoint paths.
///
/// All endpoint strings live here so they can be updated in one place
/// when the backend changes.
library;

import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiEndpoints {
  ApiEndpoints._();

  // Base
  static String get baseUrl =>
      dotenv.env['BACKEND_BASE_URL'] ??
      '';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String requestOtp = '/auth/otp/request';
  static const String resendOtp = '/auth/otp/resend';
  static const String verifyOtp = '/auth/otp/verify';
  static const String refreshToken = '/auth/refresh';
  static const String profile = '/me/profile';
  static const String preferences = '/me/preferences';

  // Maps / Geocoding
  static const String geocode = '/maps/geocode';

  // Vendors
  static const String vendors = '/vendors';
  static String vendorById(String id) => '/vendors/$id';
  static String vendorMenu(String vendorId) => '/vendors/$vendorId/menu';
  static String storeCatalog(String vendorId) => '/stores/$vendorId/catalog';

  // Orders
  static const String orders = '/orders';
  static const String ordersEstimate = '/orders/estimate';
  static String orderById(String id) => '/orders/$id';
  static String placeOrder(String id) => '/orders/$id/place';
  static String generatePaymentLink(String id) => '/orders/$id/payment-link';
  static const String orderTracking = '/orders/tracking';
  static String orderTrackingLive(String id) => '/orders/$id/tracking-live';
  static String orderTimeline(String id) => '/orders/$id/timeline';
  static String orderCancel(String id) => '/orders/$id/cancel';
  static String orderDispute(String id) => '/orders/$id/dispute';
  static String orderReviews(String id) => '/orders/$id/reviews';
  static String orderMyReview(String id) => '/orders/$id/reviews/me';

  // Payments
  static const String initializePayment = '/payments/initialize';
  // Webhook only — not called from the client.
  // static const String verifyPayment = '/payments/webhook/paystack';

  // Pay Links
  static String payLinkDetails(String token) => '/pay-links/$token';
  static String initializePayLink(String token) =>
      '/pay-links/$token/initialize';

  // Cart
  static const String cart = '/cart';

  // Location
  static const String searchLocation = '/locations/search'; // legacy

  // Group Orders
  static const String groups = '/groups';
  static String groupById(String id) => '/groups/$id';
  static String groupPoll(String groupId) => '/groups/$groupId/poll';

  // Addresses
  static const String addresses = '/me/addresses';

  // Notifications
  static const String notifications = '/me/notifications';
  static const String notificationsReadAll = '/me/notifications/read-all';
  static String notificationRead(String id) => '/me/notifications/$id/read';

  // Support
  static const String supportTickets = '/support/tickets';
  static String supportTicketById(String id) => '/support/tickets/$id';

  // Social
  static const String socialContactsSync = '/social/contacts/sync';
  static const String socialFeed = '/social/feed';
  static const String socialPreferences = '/social/preferences';

  // Home Feed
  static const String homeFeed = '/home/feed';

  // Search
  static const String search = '/search';

  // Auth — Logout
  static const String logout = '/auth/logout';
}
