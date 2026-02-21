import 'package:dropx_mobile/src/core/network/api_client.dart';
import 'package:dropx_mobile/src/core/network/api_endpoints.dart';
import 'package:dropx_mobile/src/features/order/data/dto/create_order_dto.dart';
import 'package:dropx_mobile/src/features/order/data/dto/create_order_response.dart';
import 'package:dropx_mobile/src/features/order/data/dto/initialize_payment_dto.dart';
import 'package:dropx_mobile/src/features/order/data/dto/initialize_payment_response.dart';
import 'package:dropx_mobile/src/features/order/data/dto/orders_response.dart';
import 'package:dropx_mobile/src/features/order/data/dto/place_order_dto.dart';
import 'package:dropx_mobile/src/features/order/data/dto/place_order_response.dart';
import 'package:dropx_mobile/src/features/order/data/dto/generate_payment_link_dto.dart';
import 'package:dropx_mobile/src/features/order/data/dto/generate_payment_link_response.dart';
import 'package:dropx_mobile/src/features/order/data/order_repository.dart';
import 'package:dropx_mobile/src/models/order.dart';

/// Remote implementation of [OrderRepository] using the DropX API.
class RemoteOrderRepository implements OrderRepository {
  final ApiClient _apiClient;

  RemoteOrderRepository(this._apiClient);

  @override
  Future<List<Order>> getOrders() async {
    final response = await _apiClient.get<OrdersResponse>(
      ApiEndpoints.orders,
      fromJson: (json) => OrdersResponse.fromJson(json as Map<String, dynamic>),
    );
    return response.data.orders;
  }

  @override
  Future<Order> getOrderById(String id) async {
    final response = await _apiClient.get<Order>(
      ApiEndpoints.orderById(id),
      fromJson: (json) => Order.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  @override
  Future<CreateOrderResponse> createOrder(CreateOrderDto dto) async {
    final response = await _apiClient.post<CreateOrderResponse>(
      ApiEndpoints.orders,
      data: dto.toJson(),
      headers: ApiClient.traceHeaders(),
      fromJson: (json) =>
          CreateOrderResponse.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  @override
  Future<InitializePaymentResponse> initializePayment(
    InitializePaymentDto dto,
  ) async {
    final response = await _apiClient.post<InitializePaymentResponse>(
      ApiEndpoints.initializePayment,
      data: dto.toJson(),
      headers: ApiClient.traceHeaders(),
      fromJson: (json) =>
          InitializePaymentResponse.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  @override
  Future<PlaceOrderResponse> placeOrder(
    String orderId,
    PlaceOrderDto dto,
  ) async {
    final response = await _apiClient.post<PlaceOrderResponse>(
      ApiEndpoints.placeOrder(orderId),
      data: dto.toJson(),
      headers: ApiClient.traceHeaders(),
      fromJson: (json) =>
          PlaceOrderResponse.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  @override
  Future<GeneratePaymentLinkResponse> generatePaymentLink(
    String orderId,
    GeneratePaymentLinkDto dto,
  ) async {
    final response = await _apiClient.post<GeneratePaymentLinkResponse>(
      ApiEndpoints.generatePaymentLink(orderId),
      data: dto.toJson(),
      headers: ApiClient.traceHeaders(),
      fromJson: (json) =>
          GeneratePaymentLinkResponse.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }
}
