import 'package:dropx_mobile/src/features/order/data/order_repository.dart';
import 'package:dropx_mobile/src/models/order.dart';

/// Mock implementation of [OrderRepository] for development.
class MockOrderRepository implements OrderRepository {
  static final List<Order> _mockOrders = [
    const Order(
      id: 'ord-001',
      vendorName: "Mama Put's Kitchen",
      vendorLogo: 'assets/images/vendor_banner.png',
      itemsSummary: '2x Jollof Rice & Chicken',
      date: '2025-02-14',
      price: 5000,
      status: 'Delivered',
    ),
    const Order(
      id: 'ord-002',
      vendorName: "Kofi's Grill",
      vendorLogo: 'assets/images/food_jollof.png',
      itemsSummary: '1x Grilled Chicken',
      date: '2025-02-13',
      price: 3000,
      status: 'Delivered',
    ),
    const Order(
      id: 'ord-003',
      vendorName: 'Red Star Express',
      vendorLogo: 'assets/images/vendor_banner.png',
      itemsSummary: '1x Same Day Delivery',
      date: '2025-02-12',
      price: 1500,
      status: 'Cancelled',
    ),
  ];

  @override
  Future<List<Order>> getOrders() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockOrders;
  }

  @override
  Future<Order> getOrderById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mockOrders.firstWhere(
      (o) => o.id == id,
      orElse: () => _mockOrders.first,
    );
  }

  @override
  Future<Order> placeOrder(Map<String, dynamic> orderData) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const Order(
      id: 'ord-new',
      vendorName: "Mama Put's Kitchen",
      vendorLogo: 'assets/images/vendor_banner.png',
      itemsSummary: 'New Order',
      date: '2025-02-14',
      price: 2500,
      status: 'Pending',
    );
  }

  @override
  Future<void> cancelOrder(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
