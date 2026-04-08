import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/core/network/api_client.dart';
import 'package:dropx_mobile/src/core/network/api_endpoints.dart';
import 'package:dropx_mobile/src/core/providers/core_providers.dart';
import 'package:dropx_mobile/src/core/services/session_service.dart';
import 'package:dropx_mobile/src/features/cart/data/dto/cart_dto.dart';
import 'package:dropx_mobile/src/models/menu_item.dart';
import 'package:dropx_mobile/src/models/order.dart';
import 'package:dropx_mobile/src/utils/currency_utils.dart';

/// Result of an [addToCart] call.
enum AddToCartResult { success, vendorConflict }

class CartItem {
  final MenuItem menuItem;
  final int quantity;

  const CartItem({required this.menuItem, required this.quantity});

  CartItem copyWith({MenuItem? menuItem, int? quantity}) {
    return CartItem(
      menuItem: menuItem ?? this.menuItem,
      quantity: quantity ?? this.quantity,
    );
  }
}

class CartState {
  final Map<String, CartItem> items;
  final String? vendorId;
  final String? zoneId;

  const CartState({this.items = const {}, this.vendorId, this.zoneId});

  CartState copyWith({
    Map<String, CartItem>? items,
    String? vendorId,
    String? zoneId,
  }) {
    return CartState(
      items: items ?? this.items,
      vendorId: vendorId ?? this.vendorId,
      zoneId: zoneId ?? this.zoneId,
    );
  }

  int get totalItemCount =>
      items.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => items.values.fold(
    0,
    (sum, item) => sum + (item.menuItem.price * item.quantity),
  );
}

class CartNotifier extends StateNotifier<CartState> {
  final ApiClient _apiClient;
  final SessionService _session;

  CartNotifier(this._apiClient, this._session) : super(const CartState()) {
    _loadFromServer();
  }

  // ─── Auth check ───────────────────────────────────────────────────────────

  bool get _isAuthenticated => _session.isLoggedIn;

  // ─── Server sync ──────────────────────────────────────────────────────────

  Future<void> _loadFromServer() async {
    if (!_isAuthenticated) return;
    try {
      final response = await _apiClient.get<ServerCartData>(
        ApiEndpoints.cart,
        fromJson: (json) =>
            ServerCartData.fromJson(json as Map<String, dynamic>),
      );
      final data = response.data;
      if (data.vendorId == null || data.items.isEmpty) return;

      final items = <String, CartItem>{};
      for (final si in data.items) {
        final menuItem = MenuItem(
          id: si.itemId,
          vendorId: data.vendorId!,
          name: si.name,
          priceKobo: si.unitPriceKobo,
        );
        items[si.itemId] = CartItem(menuItem: menuItem, quantity: si.qty);
      }
      state = CartState(
        items: items,
        vendorId: data.vendorId,
        zoneId: data.zoneId,
      );
      debugPrint('✅ [CART] Restored ${items.length} items from server');
    } catch (e) {
      debugPrint('ℹ️ [CART] Server cart empty or unavailable: $e');
    }
  }

  Future<void> _syncToServer() async {
    if (!_isAuthenticated) return;
    final s = state;
    if (s.vendorId == null || s.zoneId == null || s.items.isEmpty) return;

    try {
      final dto = CartSyncDto(
        vendorId: s.vendorId!,
        zoneId: s.zoneId!,
        items: s.items.values
            .map(
              (ci) => CartSyncItem(
                itemId: ci.menuItem.id,
                name: ci.menuItem.name,
                qty: ci.quantity,
                unitPriceKobo: CurrencyUtils.nairaToKobo(ci.menuItem.price),
              ),
            )
            .toList(),
      );
      await _apiClient.patch<void>(
        ApiEndpoints.cart,
        data: dto.toJson(),
        fromJson: (_) {},
      );
    } catch (e) {
      debugPrint('⚠️ [CART] Server sync failed: $e');
    }
  }

  Future<void> _clearOnServer() async {
    if (!_isAuthenticated) return;
    try {
      await _apiClient.patch<void>(
        ApiEndpoints.cartClear,
        data: {},
        fromJson: (_) {},
      );
    } catch (e) {
      debugPrint('⚠️ [CART] Server clear failed: $e');
    }
  }

  // ─── Mutations ────────────────────────────────────────────────────────────

  AddToCartResult addToCart(
    MenuItem item, {
    required String vendorId,
    required String zoneId,
  }) {
    final existingVendorId = state.vendorId;
    if (existingVendorId != null && vendorId != existingVendorId) {
      return AddToCartResult.vendorConflict;
    }

    if (state.items.containsKey(item.id)) {
      increment(item.id);
    } else {
      state = state.copyWith(
        items: {...state.items, item.id: CartItem(menuItem: item, quantity: 1)},
        vendorId: state.vendorId ?? vendorId,
        zoneId: state.zoneId ?? zoneId,
      );
      _syncToServer();
    }
    return AddToCartResult.success;
  }

  void clearAndAdd(
    MenuItem item, {
    required String vendorId,
    required String zoneId,
  }) {
    state = CartState(
      items: {item.id: CartItem(menuItem: item, quantity: 1)},
      vendorId: vendorId,
      zoneId: zoneId,
    );
    _syncToServer();
  }

  void increment(String itemId) {
    if (!state.items.containsKey(itemId)) return;
    final current = state.items[itemId]!;
    state = state.copyWith(
      items: {
        ...state.items,
        itemId: current.copyWith(quantity: current.quantity + 1),
      },
    );
    _syncToServer();
  }

  void decrement(String itemId) {
    if (!state.items.containsKey(itemId)) return;
    final current = state.items[itemId]!;
    if (current.quantity > 1) {
      state = state.copyWith(
        items: {
          ...state.items,
          itemId: current.copyWith(quantity: current.quantity - 1),
        },
      );
      _syncToServer();
    } else {
      removeFromCart(itemId);
    }
  }

  void removeFromCart(String itemId) {
    final newItems = Map<String, CartItem>.from(state.items)..remove(itemId);
    state = state.copyWith(items: newItems);
    if (newItems.isEmpty) {
      _clearOnServer();
    } else {
      _syncToServer();
    }
  }

  void clearCart() {
    state = const CartState();
    _clearOnServer();
  }

  void reorder(Order order) {
    if (order.items == null || order.items!.isEmpty) return;
    final newItems = <String, CartItem>{};
    for (final orderItem in order.items!) {
      final menuItem = MenuItem(
        id: orderItem.name,
        vendorId: order.vendorId ?? '',
        name: orderItem.name,
        priceKobo: orderItem.unitPriceKobo,
      );
      newItems[menuItem.id] = CartItem(
        menuItem: menuItem,
        quantity: orderItem.qty,
      );
    }
    state = CartState(
      items: newItems,
      vendorId: order.vendorId,
      zoneId: order.zoneId,
    );
    _syncToServer();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier(
    ref.watch(apiClientProvider),
    ref.watch(sessionServiceProvider),
  );
});
