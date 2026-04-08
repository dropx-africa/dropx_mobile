import 'package:dropx_mobile/src/models/order.dart';
import 'package:dropx_mobile/src/features/order/data/dto/orders_response.dart';
import 'package:dropx_mobile/src/features/order/data/dto/create_order_dto.dart';
import 'package:dropx_mobile/src/features/order/data/dto/create_order_response.dart';
import 'package:dropx_mobile/src/features/order/data/dto/initialize_payment_dto.dart';
import 'package:dropx_mobile/src/features/order/data/dto/initialize_payment_response.dart';
import 'package:dropx_mobile/src/features/order/data/dto/place_order_dto.dart';
import 'package:dropx_mobile/src/features/order/data/dto/place_order_response.dart';
import 'package:dropx_mobile/src/features/order/data/dto/generate_payment_link_dto.dart';
import 'package:dropx_mobile/src/features/order/data/dto/generate_payment_link_response.dart';
import 'package:dropx_mobile/src/features/order/data/dto/estimate_order_request.dart';
import 'package:dropx_mobile/src/features/order/data/dto/estimate_order_response.dart';
import 'package:dropx_mobile/src/features/order/data/dto/order_tracking_live_response.dart';
import 'package:dropx_mobile/src/features/order/data/dto/order_timeline_response.dart';
import 'package:dropx_mobile/src/features/order/data/dto/cancel_order_request.dart';
import 'package:dropx_mobile/src/features/order/data/dto/cancel_order_response.dart';
import 'package:dropx_mobile/src/features/order/data/dto/dispute_order_request.dart';
import 'package:dropx_mobile/src/features/order/data/dto/dispute_order_response.dart';
import 'package:dropx_mobile/src/features/order/data/dto/submit_review_request.dart';
import 'package:dropx_mobile/src/features/order/data/dto/submit_review_response.dart';
import 'package:dropx_mobile/src/features/order/data/dto/get_my_review_response.dart';
import 'package:dropx_mobile/src/features/order/data/dto/delivery_otp_response.dart';

/// Abstract repository interface for order & payment operations.
abstract class OrderRepository {
  /// Get orders for the current user. Pass [cursor] for pagination.
  Future<OrdersResponse> getOrders({String? cursor});

  /// Get a single order by ID.
  Future<Order> getOrderById(String id);

  /// Create a new order.
  Future<CreateOrderResponse> createOrder(CreateOrderDto dto);

  /// Initialize payment for an order (returns Paystack checkout URL).
  Future<InitializePaymentResponse> initializePayment(InitializePaymentDto dto);

  /// Place an order (e.g., using WALLET).
  Future<PlaceOrderResponse> placeOrder(String orderId, PlaceOrderDto dto);

  /// Generate a payment link for an order.
  Future<GeneratePaymentLinkResponse> generatePaymentLink(
    String orderId,
    GeneratePaymentLinkDto dto,
  );

  /// Estimate order fees before checkout.
  Future<EstimateOrderResponse> estimateOrder(EstimateOrderRequest dto);

  /// Fetch live order tracking data.
  Future<OrderTrackingLiveResponse> trackOrderLive(String orderId);

  /// Fetch order timeline.
  Future<OrderTimelineResponse> getOrderTimeline(String orderId);

  /// Cancel an order.
  Future<CancelOrderResponse> cancelOrder(
    String orderId,
    CancelOrderRequest request,
  );

  /// Dispute an order.
  Future<DisputeOrderResponse> disputeOrder(
    String orderId,
    DisputeOrderRequest request,
  );

  /// Submit a review for an order.
  Future<SubmitReviewResponse> submitReview(
    String orderId,
    SubmitReviewRequest request,
  );

  /// Get the current user's review for an order (null if none).
  Future<GetMyReviewData?> getMyReview(String orderId);

  /// Fetch the delivery OTP for an in-transit order.
  Future<DeliveryOtpData?> getDeliveryOtp(String orderId);
}
