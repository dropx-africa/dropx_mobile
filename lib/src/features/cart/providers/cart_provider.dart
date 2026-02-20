import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/models/menu_item.dart';

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

  const CartState({this.items = const {}});

  CartState copyWith({Map<String, CartItem>? items}) {
    return CartState(items: items ?? this.items);
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

  void addToCart(MenuItem item) {
    if (state.items.containsKey(item.id)) {
      increment(item.id);
    } else {
      state = state.copyWith(
        items: {
          ...state.items,
          item.id: CartItem(menuItem: item, quantity: 1),
        },
      );
    }
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
