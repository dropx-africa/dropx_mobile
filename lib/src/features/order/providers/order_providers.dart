import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/core/providers/core_providers.dart';
import 'package:dropx_mobile/src/features/order/data/order_repository.dart';
import 'package:dropx_mobile/src/features/order/data/remote_order_repository.dart';
import 'package:dropx_mobile/src/features/order/data/dto/create_order_dto.dart';
import 'package:dropx_mobile/src/features/order/data/dto/create_order_response.dart';
import 'package:dropx_mobile/src/features/order/data/dto/initialize_payment_dto.dart';
import 'package:dropx_mobile/src/features/order/data/dto/initialize_payment_response.dart';
import 'package:dropx_mobile/src/models/order.dart';

/// ─── Repository Provider ──────────────────────────────────────
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return RemoteOrderRepository(ref.watch(apiClientProvider));
});

/// ─── Data Providers ───────────────────────────────────────────

/// First page of orders — used by RecentOrdersSection on home tab.
final ordersProvider = FutureProvider<List<Order>>((ref) async {
  final response = await ref.watch(orderRepositoryProvider).getOrders();
  return response.orders;
});

/// Single order by ID.
final orderByIdProvider = FutureProvider.family<Order, String>((ref, id) {
  return ref.watch(orderRepositoryProvider).getOrderById(id);
});

/// Create a new order — pass a [CreateOrderDto] as the argument.
final createOrderProvider =
    FutureProvider.family<CreateOrderResponse, CreateOrderDto>((ref, dto) {
      return ref.watch(orderRepositoryProvider).createOrder(dto);
    });

/// Initialize payment for an order — pass an [InitializePaymentDto].
final initializePaymentProvider =
    FutureProvider.family<InitializePaymentResponse, InitializePaymentDto>((
      ref,
      dto,
    ) {
      return ref.watch(orderRepositoryProvider).initializePayment(dto);
    });
