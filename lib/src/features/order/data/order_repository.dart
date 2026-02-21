import 'package:dropx_mobile/src/models/order.dart';
import 'package:dropx_mobile/src/features/order/data/dto/create_order_dto.dart';
import 'package:dropx_mobile/src/features/order/data/dto/create_order_response.dart';
import 'package:dropx_mobile/src/features/order/data/dto/initialize_payment_dto.dart';
import 'package:dropx_mobile/src/features/order/data/dto/initialize_payment_response.dart';
import 'package:dropx_mobile/src/features/order/data/dto/place_order_dto.dart';
import 'package:dropx_mobile/src/features/order/data/dto/place_order_response.dart';
import 'package:dropx_mobile/src/features/order/data/dto/generate_payment_link_dto.dart';
import 'package:dropx_mobile/src/features/order/data/dto/generate_payment_link_response.dart';

/// Abstract repository interface for order & payment operations.
abstract class OrderRepository {
  /// Get all orders for the current user.
  Future<List<Order>> getOrders();

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
}
