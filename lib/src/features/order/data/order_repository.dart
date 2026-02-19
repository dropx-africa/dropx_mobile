import 'package:dropx_mobile/src/models/order.dart';

/// Abstract repository interface for order-related data operations.
abstract class OrderRepository {
  /// Get all orders for the current user.
  Future<List<Order>> getOrders();

  /// Get a single order by ID.
  Future<Order> getOrderById(String id);

  /// Place a new order.
  Future<Order> placeOrder(Map<String, dynamic> orderData);

  /// Cancel an order.
  Future<void> cancelOrder(String orderId);
}
