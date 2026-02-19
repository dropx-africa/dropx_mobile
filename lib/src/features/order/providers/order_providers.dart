import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/features/order/data/order_repository.dart';
import 'package:dropx_mobile/src/features/order/data/mock_order_repository.dart';
import 'package:dropx_mobile/src/models/order.dart';

/// ─── Repository Provider ──────────────────────────────────────
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  // TODO: Swap to OrderRepositoryImpl(ref.watch(apiClientProvider))
  return MockOrderRepository();
});

/// ─── Data Providers ───────────────────────────────────────────

/// All orders for the current user.
final ordersProvider = FutureProvider<List<Order>>((ref) {
  return ref.watch(orderRepositoryProvider).getOrders();
});

/// Single order by ID.
final orderByIdProvider = FutureProvider.family<Order, String>((ref, id) {
  return ref.watch(orderRepositoryProvider).getOrderById(id);
});
