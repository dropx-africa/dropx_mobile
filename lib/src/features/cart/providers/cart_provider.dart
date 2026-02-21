import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/models/menu_item.dart';

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

  /// The vendor whose items are in the cart.
  final String? vendorId;

  /// The zone used when the vendor was loaded.
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
  CartNotifier() : super(const CartState());

  /// Add an item to the cart.
  ///
  /// Returns [AddToCartResult.success] if added, or
  /// [AddToCartResult.vendorConflict] if the cart already contains items
  /// from a different vendor.
  AddToCartResult addToCart(
    MenuItem item, {
    required String vendorId,
    required String zoneId,
  }) {
    // Check vendor conflict: if cart has items from a different vendor
    final existingVendorId = state.vendorId;
    if (existingVendorId != null && vendorId != existingVendorId) {
      return AddToCartResult.vendorConflict;
    }

    if (state.items.containsKey(item.id)) {
      increment(item.id);
    } else {
      state = state.copyWith(
        items: {
          ...state.items,
          item.id: CartItem(menuItem: item, quantity: 1),
        },
        vendorId: state.vendorId ?? vendorId,
        zoneId: state.zoneId ?? zoneId,
      );
    }
    return AddToCartResult.success;
  }

  /// Clear the cart and add the given item (used after vendor conflict confirm).
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
  }

  void increment(String itemId) {
    if (!state.items.containsKey(itemId)) return;

    final currentItem = state.items[itemId]!;
    final updatedItem = currentItem.copyWith(
      quantity: currentItem.quantity + 1,
    );

    state = state.copyWith(items: {...state.items, itemId: updatedItem});
  }

  void decrement(String itemId) {
    if (!state.items.containsKey(itemId)) return;

    final currentItem = state.items[itemId]!;
    if (currentItem.quantity > 1) {
      final updatedItem = currentItem.copyWith(
        quantity: currentItem.quantity - 1,
      );
      state = state.copyWith(items: {...state.items, itemId: updatedItem});
    } else {
      removeFromCart(itemId);
    }
  }

  void removeFromCart(String itemId) {
    final newItems = Map<String, CartItem>.from(state.items);
    newItems.remove(itemId);
    state = state.copyWith(items: newItems);
  }

  void clearCart() {
    state = const CartState();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});
