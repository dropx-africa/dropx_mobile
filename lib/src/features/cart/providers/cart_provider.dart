import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/core/providers/core_providers.dart';
import 'package:dropx_mobile/src/core/services/session_service.dart';
import 'package:dropx_mobile/src/features/cart/data/cart_repository.dart';
import 'package:dropx_mobile/src/features/cart/data/remote_cart_repository.dart';
import 'package:dropx_mobile/src/features/cart/data/dto/cart_dto.dart';
import 'package:dropx_mobile/src/models/menu_item.dart';
import 'package:dropx_mobile/src/models/order.dart';
import 'package:dropx_mobile/src/utils/currency_utils.dart';

enum AddToCartResult { success, vendorConflict }

int _toInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

class CartItem {
  final MenuItem menuItem;
  final int quantity;
  final MenuItemVariant? selectedVariant;
  final List<MenuItemAddon> selectedAddons;

  const CartItem({
    required this.menuItem,
    required this.quantity,
    this.selectedVariant,
    this.selectedAddons = const [],
  });

  CartItem copyWith({
    MenuItem? menuItem,
    int? quantity,
    MenuItemVariant? selectedVariant,
    List<MenuItemAddon>? selectedAddons,
  }) {
    return CartItem(
      menuItem: menuItem ?? this.menuItem,
      quantity: quantity ?? this.quantity,
      selectedVariant: selectedVariant ?? this.selectedVariant,
      selectedAddons: selectedAddons ?? this.selectedAddons,
    );
  }

  String get lineKey {
    final parts = <String>[menuItem.id];
    if (selectedVariant != null) parts.add(selectedVariant!.variantId);
    for (final a in selectedAddons) {
      parts.add(a.addonId);
    }
    return parts.join('::');
  }
}

class CartState {
  final Map<String, CartItem> items; // keyed by item_id for easy lookup
  final String? vendorId;
  final String? vendorName;
  final String? zoneId;

  const CartState({
    this.items = const {},
    this.vendorId,
    this.vendorName,
    this.zoneId,
  });

  CartState copyWith({
    Map<String, CartItem>? items,
    String? vendorId,
    String? vendorName,
    String? zoneId,
  }) {
    return CartState(
      items: items ?? this.items,
      vendorId: vendorId ?? this.vendorId,
      vendorName: vendorName ?? this.vendorName,
      zoneId: zoneId ?? this.zoneId,
    );
  }

  int get totalItemCount =>
      items.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => items.values.fold(0, (sum, item) {
    final variantDelta = item.selectedVariant?.priceDelta ?? 0.0;
    final addonTotal = item.selectedAddons.fold<double>(
      0,
      (s, a) => s + a.price,
    );
    return sum + ((item.menuItem.price + variantDelta + addonTotal) * item.quantity);
  });
}

class CartNotifier extends StateNotifier<CartState> {
  final CartRepository _repo;
  final SessionService _session;

  CartNotifier(this._repo, this._session) : super(const CartState()) {
    _loadFromServer();
  }

  bool get _isAuthenticated => _session.isLoggedIn;

  Future<void> _loadFromServer() async {
    if (!_isAuthenticated) return;
    try {
      final data = await _repo.getCart();
      if (data.vendor == null || data.items.isEmpty) return;

      final items = <String, CartItem>{};
      for (final li in data.items) {
        final detail = li.item;
        final config = li.configuration;

        final menuItem = MenuItem(
          id: detail.itemId,
          vendorId: detail.vendorId,
          name: detail.name,
          priceKobo: detail.priceKobo,
          category: detail.category,
          description: detail.description,
          imageUrl: detail.imageUrl,
        );

        MenuItemVariant? variant;
        if (config?.selectedVariant != null) {
          final sv = config!.selectedVariant!;
          variant = MenuItemVariant(
            variantId: sv.variantId,
            name: sv.name,
            priceDeltaKobo: sv.priceDeltaKobo,
            isDefault: sv.isDefault,
          );
        }

        final addons = (config?.selectedAddons ?? [])
            .map(
              (a) => MenuItemAddon(
                addonId: a.addonId,
                groupName: '',
                name: a.name,
                priceKobo: a.priceKobo,
              ),
            )
            .toList();

        items[detail.itemId] = CartItem(
          menuItem: menuItem,
          quantity: li.quantity,
          selectedVariant: variant,
          selectedAddons: addons,
        );
      }

      state = CartState(
        items: items,
        vendorId: data.vendor!.vendorId,
        vendorName: data.vendor!.displayName,
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
      final lineItems = s.items.values.map((ci) {
        final item = ci.menuItem;
        final variant = ci.selectedVariant;
        final addons = ci.selectedAddons;

        return CartLineItem(
          lineKey: ci.lineKey,
          quantity: ci.quantity,
          item: CartLineItemDetail(
            itemId: item.id,
            vendorId: item.vendorId ?? s.vendorId!,
            category: item.category,
            name: item.name,
            description: item.description,
            priceKobo: CurrencyUtils.nairaToKobo(item.price),
            imageUrl: item.imageUrl,
            isAvailable: item.isAvailable,
          ),
          configuration: CartItemConfiguration(
            selectedVariant: variant != null
                ? CartSelectedVariant(
                    variantId: variant.variantId,
                    name: variant.name,
                    priceDeltaKobo: _toInt(variant.priceDeltaKobo),
                    isDefault: variant.isDefault,
                  )
                : null,
            selectedAddons: addons
                .map(
                  (a) => CartSelectedAddon(
                    addonId: a.addonId,
                    name: a.name,
                    priceKobo: _toInt(a.priceKobo),
                  ),
                )
                .toList(),
          ),
        );
      }).toList();

      await _repo.syncCart(
        CartSyncDto(
          vendor: CartVendorInfo(
            vendorId: s.vendorId!,
            displayName: s.vendorName ?? s.vendorId!,
            zoneId: s.zoneId!,
          ),
          items: lineItems,
          checkoutLine1: _session.savedAddress.isNotEmpty
              ? _session.savedAddress
              : 'My Location',
          checkoutCity: _session.savedCity.isNotEmpty
              ? _session.savedCity
              : 'Lagos',
          checkoutState: _session.savedState.isNotEmpty
              ? _session.savedState
              : 'Lagos',
        ),
      );
    } catch (e) {
      debugPrint('⚠️ [CART] Server sync failed: $e');
    }
  }

  Future<void> _clearOnServer() async {
    if (!_isAuthenticated) return;
    try {
      await _repo.clearCart();
    } catch (e) {
      debugPrint('⚠️ [CART] Server clear failed: $e');
    }
  }

  // ─── Mutations ────────────────────────────────────────────────────────────

  AddToCartResult addToCart(
    MenuItem item, {
    required String vendorId,
    required String vendorName,
    required String zoneId,
    MenuItemVariant? selectedVariant,
    List<MenuItemAddon> selectedAddons = const [],
  }) {
    final existingVendorId = state.vendorId;
    if (existingVendorId != null &&
        state.items.isNotEmpty &&
        vendorId != existingVendorId) {
      return AddToCartResult.vendorConflict;
    }

    if (state.items.containsKey(item.id)) {
      increment(item.id);
    } else {
      state = state.copyWith(
        items: {
          ...state.items,
          item.id: CartItem(
            menuItem: item,
            quantity: 1,
            selectedVariant: selectedVariant,
            selectedAddons: selectedAddons,
          ),
        },
        vendorId: state.vendorId ?? vendorId,
        vendorName: state.vendorName ?? vendorName,
        zoneId: state.zoneId ?? zoneId,
      );
      _syncToServer();
    }
    return AddToCartResult.success;
  }

  void clearAndAdd(
    MenuItem item, {
    required String vendorId,
    required String vendorName,
    required String zoneId,
    MenuItemVariant? selectedVariant,
    List<MenuItemAddon> selectedAddons = const [],
  }) {
    state = CartState(
      items: {
        item.id: CartItem(
          menuItem: item,
          quantity: 1,
          selectedVariant: selectedVariant,
          selectedAddons: selectedAddons,
        ),
      },
      vendorId: vendorId,
      vendorName: vendorName,
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

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return RemoteCartRepository(ref.watch(apiClientProvider));
});

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier(
    ref.watch(cartRepositoryProvider),
    ref.watch(sessionServiceProvider),
  );
});
