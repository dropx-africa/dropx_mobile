/// Centralized API endpoint paths.
///
/// All endpoint strings live here so they can be updated in one place
/// when the backend changes.
library;

import '../app_config.dart';

class ApiEndpoints {
  ApiEndpoints._();

  // Base
  static const String baseUrl = AppConfig.backendBaseUrl;

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String requestOtp = '/auth/otp/request';
  static const String resendOtp = '/auth/otp/resend';
  static const String verifyOtp = '/auth/otp/verify';
  static const String refreshToken = '/auth/refresh';
  static const String resetPassword = '/auth/reset-password';
  static const String profile = '/me/profile';
  static const String preferences = '/me/preferences';

  // Maps / Geocoding
  static const String geocode = '/maps/geocode';

  // Vendors
  static const String vendors = '/vendors';
  static String vendorById(String id) => '/vendors/$id';
  static String vendorMenu(String vendorId) => '/vendors/$vendorId/menu';
  static String storeCatalog(String vendorId) => '/stores/$vendorId/catalog';
  static String storeItem(String vendorId, String itemId) => '/stores/$vendorId/items/$itemId';

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
  static String orderDeliveryOtp(String id) => '/orders/$id/delivery-otp';
  static String orderPaymentStatus(String id) => '/orders/$id/payment-status';

  // Parcels
  static const String parcelsPaymentOptions = '/parcels/payment-options';
  static const String parcelsQuote = '/parcels/quote';
  static const String parcels = '/parcels';
  static String parcelById(String id) => '/parcels/$id';
  static String parcelPlace(String id) => '/parcels/$id/place';
  static String parcelPaymentLink(String id) => '/parcels/$id/payment-link';
  static String parcelPaymentInitialize(String id) =>
      '/parcels/$id/payments/initialize';
  static String parcelPaymentVerify(String id) =>
      '/parcels/$id/payments/verify/paystack';
  static String parcelRecipientConfirm(String id) =>
      '/parcels/$id/recipient-confirmation/verify';
  static String parcelTrackingLive(String id) =>
      '/parcels/$id/tracking-live';

  // SSE
  static String sseOrder(String id) => '/sse/orders/$id';
  static String sseParcel(String id) => '/sse/parcels/$id';

  // Payments
  static const String initializePayment = '/payments/initialize';
  // Webhook only — not called from the client.
  // static const String verifyPayment = '/payments/webhook/paystack';

  // Pay Links
  static String payLinkDetails(String token) => '/pay-links/$token';
  static String initializePayLink(String token) =>
      '/pay-links/$token/initialize';

  // Cart
  static const String cart = '/me/cart';
  static const String cartClear = '/me/cart/clear';

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

  // Wallet
  static const String wallet = '/me/wallet';
  static const String walletLedger = '/me/wallet/ledger';
  static const String walletTopupInitialize = '/me/wallet/topup/initialize';
  static const String walletTopupVerify = '/me/wallet/topup/verify';

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

  // Auth — Password Reset
  static const String passwordResetRequest = '/auth/password/reset/request';
  static const String passwordResetVerify = '/auth/password/reset/verify';
  static const String passwordResetComplete = '/auth/password/reset/complete';
  static const String passwordResetResend = '/auth/password/reset/resend';
}
