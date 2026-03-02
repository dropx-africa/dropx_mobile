import 'package:flutter/foundation.dart';
import 'package:dropx_mobile/src/core/network/api_client.dart';
import 'package:dropx_mobile/src/core/network/api_endpoints.dart';
import 'package:dropx_mobile/src/core/network/api_exceptions.dart';
import 'package:dropx_mobile/src/features/order/data/dto/create_order_dto.dart';
import 'package:dropx_mobile/src/features/order/data/dto/create_order_response.dart';
import 'package:dropx_mobile/src/features/order/data/dto/initialize_payment_dto.dart';
import 'package:dropx_mobile/src/features/order/data/dto/initialize_payment_response.dart';
import 'package:dropx_mobile/src/features/order/data/dto/orders_response.dart';
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
import 'package:dropx_mobile/src/features/order/data/order_repository.dart';
import 'package:dropx_mobile/src/models/order.dart';

/// Remote implementation of [OrderRepository] using the DropX API.
class RemoteOrderRepository implements OrderRepository {
  final ApiClient _apiClient;

  RemoteOrderRepository(this._apiClient);

  @override
  Future<List<Order>> getOrders() async {
    debugPrint(
      '🔵 [ORDER-API] GET ${ApiEndpoints.baseUrl}${ApiEndpoints.orders}',
    );
    final response = await _apiClient.get<OrdersResponse>(
      ApiEndpoints.orders,
      fromJson: (json) => OrdersResponse.fromJson(json as Map<String, dynamic>),
    );
    debugPrint(
      '✅ [ORDER-API] GET /orders → ${response.data.orders.length} orders',
    );
    return response.data.orders;
  }

  @override
  Future<Order> getOrderById(String id) async {
    debugPrint(
      '🔵 [ORDER-API] GET ${ApiEndpoints.baseUrl}${ApiEndpoints.orderById(id)}',
    );
    final response = await _apiClient.get<Order>(
      ApiEndpoints.orderById(id),
      fromJson: (json) => Order.fromJson(json as Map<String, dynamic>),
    );
    debugPrint(
      '✅ [ORDER-API] GET /orders/$id → orderId=${response.data.orderId}',
    );
    return response.data;
  }

  @override
  Future<CreateOrderResponse> createOrder(CreateOrderDto dto) async {
    final body = dto.toJson();
    debugPrint(
      '🟡 [ORDER-API] POST ${ApiEndpoints.baseUrl}${ApiEndpoints.orders}',
    );
    debugPrint('   📦 Body: $body');
    final response = await _apiClient.post<CreateOrderResponse>(
      ApiEndpoints.orders,
      data: body,
      headers: ApiClient.traceHeaders(),
      fromJson: (json) =>
          CreateOrderResponse.fromJson(json as Map<String, dynamic>),
    );
    debugPrint(
      '✅ [ORDER-API] POST /orders → orderId=${response.data.order.orderId}',
    );
    return response.data;
  }

  @override
  Future<InitializePaymentResponse> initializePayment(
    InitializePaymentDto dto,
  ) async {
    final body = dto.toJson();
    debugPrint(
      '🟡 [PAYMENT-API] POST ${ApiEndpoints.baseUrl}${ApiEndpoints.initializePayment}',
    );
    debugPrint('   📦 Body: $body');
    final response = await _apiClient.post<InitializePaymentResponse>(
      ApiEndpoints.initializePayment,
      data: body,
      headers: ApiClient.traceHeaders(),
      fromJson: (json) =>
          InitializePaymentResponse.fromJson(json as Map<String, dynamic>),
    );
    debugPrint(
      '✅ [PAYMENT-API] POST /payments/initialize → ref=${response.data.reference}',
    );
    return response.data;
  }

  @override
  Future<PlaceOrderResponse> placeOrder(
    String orderId,
    PlaceOrderDto dto,
  ) async {
    final body = dto.toJson();
    debugPrint(
      '🟡 [ORDER-API] POST ${ApiEndpoints.baseUrl}${ApiEndpoints.placeOrder(orderId)}',
    );
    debugPrint('   📦 Body: $body');
    final response = await _apiClient.post<PlaceOrderResponse>(
      ApiEndpoints.placeOrder(orderId),
      data: body,
      headers: ApiClient.traceHeaders(),
      fromJson: (json) =>
          PlaceOrderResponse.fromJson(json as Map<String, dynamic>),
    );
    debugPrint('✅ [ORDER-API] POST /orders/$orderId/place → success');
    return response.data;
  }

  @override
  Future<GeneratePaymentLinkResponse> generatePaymentLink(
    String orderId,
    GeneratePaymentLinkDto dto,
  ) async {
    final body = dto.toJson();
    debugPrint(
      '🟡 [ORDER-API] POST ${ApiEndpoints.baseUrl}${ApiEndpoints.generatePaymentLink(orderId)}',
    );
    debugPrint('   📦 Body: $body');
    final response = await _apiClient.post<GeneratePaymentLinkResponse>(
      ApiEndpoints.generatePaymentLink(orderId),
      data: body,
      headers: ApiClient.traceHeaders(),
      fromJson: (json) =>
          GeneratePaymentLinkResponse.fromJson(json as Map<String, dynamic>),
    );
    debugPrint(
      '✅ [ORDER-API] POST /orders/$orderId/payment-link → token=${response.data.token}',
    );
    return response.data;
  }

  @override
  Future<EstimateOrderResponse> estimateOrder(EstimateOrderRequest dto) async {
    final body = dto.toJson();
    debugPrint(
      '🟡 [ORDER-API] POST ${ApiEndpoints.baseUrl}${ApiEndpoints.ordersEstimate}',
    );
    debugPrint('   📦 Body: $body');
    // ApiClient._processResponse already unwraps json['data'], so fromJson
    // receives the inner data object directly (not the {ok, data} envelope).
    final response = await _apiClient.post<EstimateOrderData>(
      ApiEndpoints.ordersEstimate,
      data: body,
      headers: ApiClient.traceHeaders(),
      fromJson: (json) =>
          EstimateOrderData.fromJson(json as Map<String, dynamic>),
    );
    final data = response.data;
    debugPrint('✅ [ORDER-API] POST /orders/estimate →');
    debugPrint('   delivery_fee_kobo=${data.deliveryFeeKobo}');
    debugPrint('   service_fee_kobo=${data.serviceFeeKobo}');
    debugPrint('   subtotal_kobo=${data.subtotalKobo}');
    debugPrint('   total_kobo=${data.totalKobo}');
    debugPrint('   eta_minutes=${data.etaMinutes}');
    debugPrint('   quote_id=${data.quoteId}');
    // Wrap back into EstimateOrderResponse for the interface contract.
    return EstimateOrderResponse(ok: true, data: data);
  }

  @override
  Future<OrderTrackingLiveResponse> trackOrderLive(String orderId) async {
    debugPrint(
      '🔵 [TRACKING-API] GET ${ApiEndpoints.baseUrl}${ApiEndpoints.orderTrackingLive(orderId)}',
    );
    // ApiClient already unwraps json['data'], so we parse the inner
    // OrderTrackingLiveData directly.
    final response = await _apiClient.get<OrderTrackingLiveData>(
      ApiEndpoints.orderTrackingLive(orderId),
      headers: ApiClient.traceHeaders(),
      fromJson: (json) =>
          OrderTrackingLiveData.fromJson(json as Map<String, dynamic>),
    );
    final data = response.data;
    debugPrint('✅ [TRACKING-API] GET /orders/$orderId/tracking-live →');
    debugPrint('   state=${data.state}, eta_minutes=${data.etaMinutes}');
    debugPrint('   rider=${data.rider?.name ?? "none"}');
    debugPrint(
      '   location=${data.location != null ? "${data.location!.lat},${data.location!.lng}" : "none"}',
    );
    return OrderTrackingLiveResponse(ok: true, data: data);
  }

  @override
  Future<OrderTimelineResponse> getOrderTimeline(String orderId) async {
    debugPrint(
      '🔵 [TIMELINE-API] GET ${ApiEndpoints.baseUrl}${ApiEndpoints.orderTimeline(orderId)}',
    );
    // The timeline endpoint returns a flat structure. ApiClient unwraps
    // json['data'] which removes the 'ok' field. Parse the inner data
    // fields directly.
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.orderTimeline(orderId),
      headers: ApiClient.traceHeaders(),
      fromJson: (json) => json as Map<String, dynamic>,
    );
    final raw = response.data;
    // Build the response manually from the unwrapped data
    final timeline = OrderTimelineResponse(
      ok: true,
      orderId: raw['order_id'] as String? ?? orderId,
      state: raw['state'] as String? ?? 'UNKNOWN',
      rider: raw['rider'],
      etaMinutes: (raw['eta_minutes'] as num?)?.toInt(),
      timeline: (raw['timeline'] as List<dynamic>? ?? [])
          .map((e) => TimelineEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      location: raw['location'],
    );
    debugPrint(
      '✅ [TIMELINE-API] GET /orders/$orderId/timeline → state=${timeline.state}',
    );
    return timeline;
  }

  @override
  Future<CancelOrderResponse> cancelOrder(
    String orderId,
    CancelOrderRequest request,
  ) async {
    final body = request.toJson();
    debugPrint(
      '🔴 [ORDER-API] POST ${ApiEndpoints.baseUrl}${ApiEndpoints.orderCancel(orderId)}',
    );
    debugPrint('   📦 Body: $body');
    // ApiClient already unwraps json['data'], parse CancelOrderData directly.
    final response = await _apiClient.post<CancelOrderData>(
      ApiEndpoints.orderCancel(orderId),
      data: body,
      headers: ApiClient.traceHeaders(),
      fromJson: (json) =>
          CancelOrderData.fromJson(json as Map<String, dynamic>),
    );
    debugPrint(
      '✅ [ORDER-API] POST /orders/$orderId/cancel → state=${response.data.state}',
    );
    return CancelOrderResponse(ok: true, data: response.data);
  }

  @override
  Future<DisputeOrderResponse> disputeOrder(
    String orderId,
    DisputeOrderRequest request,
  ) async {
    final body = request.toJson();
    debugPrint(
      '🔴 [ORDER-API] POST ${ApiEndpoints.baseUrl}${ApiEndpoints.orderDispute(orderId)}',
    );
    debugPrint('   📦 Body: $body');
    // ApiClient already unwraps json['data'], parse DisputeOrderData directly.
    final response = await _apiClient.post<DisputeOrderData>(
      ApiEndpoints.orderDispute(orderId),
      data: body,
      headers: ApiClient.traceHeaders(),
      fromJson: (json) =>
          DisputeOrderData.fromJson(json as Map<String, dynamic>),
    );
    debugPrint(
      '✅ [ORDER-API] POST /orders/$orderId/dispute → status=${response.data.status}',
    );
    return DisputeOrderResponse(ok: true, data: response.data);
  }

  @override
  Future<SubmitReviewResponse> submitReview(
    String orderId,
    SubmitReviewRequest request,
  ) async {
    final body = request.toJson();
    debugPrint(
      '🟡 [ORDER-API] POST ${ApiEndpoints.baseUrl}${ApiEndpoints.orderReviews(orderId)}',
    );
    debugPrint('   📦 Body: $body');
    final response = await _apiClient.post<SubmitReviewData>(
      ApiEndpoints.orderReviews(orderId),
      data: body,
      headers: ApiClient.traceHeaders(),
      fromJson: (json) =>
          SubmitReviewData.fromJson(json as Map<String, dynamic>),
    );
    debugPrint(
      '✅ [ORDER-API] POST /orders/$orderId/reviews → reviewId=${response.data.reviewId}',
    );
    return SubmitReviewResponse(ok: true, data: response.data);
  }

  @override
  Future<GetMyReviewData?> getMyReview(String orderId) async {
    try {
      debugPrint(
        '🔵 [ORDER-API] GET ${ApiEndpoints.baseUrl}${ApiEndpoints.orderMyReview(orderId)}',
      );
      final response = await _apiClient.get<GetMyReviewData>(
        ApiEndpoints.orderMyReview(orderId),
        headers: ApiClient.traceHeaders(),
        fromJson: (json) =>
            GetMyReviewData.fromJson(json as Map<String, dynamic>),
      );
      debugPrint(
        '✅ [ORDER-API] GET /orders/$orderId/reviews/me → rating=${response.data.review.ratingOverall}',
      );
      return response.data;
    } on NotFoundException catch (_) {
      debugPrint('ℹ️ [ORDER-API] No review found for order $orderId');
      return null;
    } catch (e) {
      debugPrint('❌ [ORDER-API] getMyReview failed: $e');
      return null;
    }
  }
}
