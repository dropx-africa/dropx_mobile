part 'cart_dto.g.dart';

// ─── GET /me/cart response ────────────────────────────────────────────────
// All read classes use manual fromJson — no code-gen needed.

class ServerCartResponse {
  final bool ok;
  final ServerCartData data;

  const ServerCartResponse({required this.ok, required this.data});

  factory ServerCartResponse.fromJson(Map<String, dynamic> json) =>
      ServerCartResponse(
        ok: json['ok'] as bool,
        data: ServerCartData.fromJson(json['data'] as Map<String, dynamic>),
      );
}

class ServerCartData {
  final ServerCartVendorInfo? vendor;
  final List<ServerCartLineItem> items;

  const ServerCartData({this.vendor, this.items = const []});

  factory ServerCartData.fromJson(Map<String, dynamic> json) =>
      ServerCartData(
        vendor: json['vendor'] != null
            ? ServerCartVendorInfo.fromJson(
                json['vendor'] as Map<String, dynamic>,
              )
            : null,
        items: (json['items'] as List<dynamic>? ?? [])
            .map((e) => ServerCartLineItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class ServerCartVendorInfo {
  final String vendorId;
  final String displayName;

  const ServerCartVendorInfo({
    required this.vendorId,
    required this.displayName,
  });

  factory ServerCartVendorInfo.fromJson(Map<String, dynamic> json) =>
      ServerCartVendorInfo(
        vendorId: json['vendor_id'] as String,
        displayName: json['display_name'] as String? ?? '',
      );
}

class ServerCartLineItem {
  final String lineKey;
  final int quantity;
  final int unitPriceKobo;
  final ServerCartItemDetail item;
  final ServerCartItemConfig? configuration;

  const ServerCartLineItem({
    required this.lineKey,
    required this.quantity,
    required this.unitPriceKobo,
    required this.item,
    this.configuration,
  });

  factory ServerCartLineItem.fromJson(Map<String, dynamic> json) =>
      ServerCartLineItem(
        lineKey: json['line_key'] as String,
        quantity: (json['quantity'] as num).toInt(),
        unitPriceKobo: (json['unit_price_kobo'] as num).toInt(),
        item: ServerCartItemDetail.fromJson(
          json['item'] as Map<String, dynamic>,
        ),
        configuration: json['configuration'] != null
            ? ServerCartItemConfig.fromJson(
                json['configuration'] as Map<String, dynamic>,
              )
            : null,
      );
}

class ServerCartItemDetail {
  final String itemId;
  final String vendorId;
  final String name;
  final int priceKobo;
  final String? category;
  final String? description;
  final String? imageUrl;

  const ServerCartItemDetail({
    required this.itemId,
    required this.vendorId,
    required this.name,
    required this.priceKobo,
    this.category,
    this.description,
    this.imageUrl,
  });

  factory ServerCartItemDetail.fromJson(Map<String, dynamic> json) =>
      ServerCartItemDetail(
        itemId: json['item_id'] as String,
        vendorId: json['vendor_id'] as String? ?? '',
        name: json['name'] as String,
        priceKobo: (json['price_kobo'] as num).toInt(),
        category: json['category'] as String?,
        description: json['description'] as String?,
        imageUrl: json['image_url'] as String?,
      );
}

class ServerCartItemConfig {
  final ServerCartVariant? selectedVariant;
  final List<ServerCartAddon> selectedAddons;

  const ServerCartItemConfig({
    this.selectedVariant,
    this.selectedAddons = const [],
  });

  factory ServerCartItemConfig.fromJson(Map<String, dynamic> json) =>
      ServerCartItemConfig(
        selectedVariant: json['selected_variant'] != null
            ? ServerCartVariant.fromJson(
                json['selected_variant'] as Map<String, dynamic>,
              )
            : null,
        selectedAddons: (json['selected_addons'] as List<dynamic>? ?? [])
            .map((e) => ServerCartAddon.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class ServerCartVariant {
  final String variantId;
  final String name;
  final int priceDeltaKobo;
  final bool isDefault;

  const ServerCartVariant({
    required this.variantId,
    required this.name,
    required this.priceDeltaKobo,
    required this.isDefault,
  });

  factory ServerCartVariant.fromJson(Map<String, dynamic> json) =>
      ServerCartVariant(
        variantId: json['variant_id'] as String,
        name: json['name'] as String,
        priceDeltaKobo: (json['price_delta_kobo'] as num).toInt(),
        isDefault: json['is_default'] as bool? ?? false,
      );
}

class ServerCartAddon {
  final String addonId;
  final String name;
  final int priceKobo;

  const ServerCartAddon({
    required this.addonId,
    required this.name,
    required this.priceKobo,
  });

  factory ServerCartAddon.fromJson(Map<String, dynamic> json) =>
      ServerCartAddon(
        addonId: json['addon_id'] as String,
        name: json['name'] as String,
        priceKobo: (json['price_kobo'] as num).toInt(),
      );
}

// ─── PATCH /me/cart body ─────────────────────────────────────────────────
// Written manually — no code-gen needed for write-only DTOs.

class CartSyncDto {
  final CartVendorInfo vendor;
  final List<CartLineItem> items;
  final String checkoutLine1;
  final String checkoutCity;
  final String checkoutState;

  const CartSyncDto({
    required this.vendor,
    required this.items,
    this.checkoutLine1 = 'My Location',
    this.checkoutCity = 'Lagos',
    this.checkoutState = 'Lagos',
  });

  Map<String, dynamic> toJson() => {
    'vendor': vendor.toJson(),
    'items': items.map((e) => e.toJson()).toList(),
    'checkout_address': {
      'line1': checkoutLine1,
      'city': checkoutCity,
      'state': checkoutState,
    },
    'payment_choice': 'PAYSTACK',
  };
}

class CartVendorInfo {
  final String vendorId;
  final String displayName;
  final String zoneId;

  const CartVendorInfo({
    required this.vendorId,
    required this.displayName,
    required this.zoneId,
  });

  Map<String, dynamic> toJson() => {
    'vendor_id': vendorId,
    'display_name': displayName,
    'zone_id': zoneId,
  };
}

class CartLineItem {
  final String lineKey;
  final int quantity;
  final CartLineItemDetail item;
  final CartItemConfiguration configuration;

  const CartLineItem({
    required this.lineKey,
    required this.quantity,
    required this.item,
    required this.configuration,
  });

  Map<String, dynamic> toJson() => {
    'line_key': lineKey,
    'quantity': quantity,
    'item': item.toJson(),
    'configuration': configuration.toJson(),
  };
}

class CartLineItemDetail {
  final String itemId;
  final String vendorId;
  final String? category;
  final String name;
  final String? description;
  final int priceKobo;
  final String? imageUrl;
  final bool isAvailable;

  const CartLineItemDetail({
    required this.itemId,
    required this.vendorId,
    this.category,
    required this.name,
    this.description,
    required this.priceKobo,
    this.imageUrl,
    this.isAvailable = true,
  });

  Map<String, dynamic> toJson() => {
    'item_id': itemId,
    'vendor_id': vendorId,
    if (category != null) 'category': category,
    'name': name,
    if (description != null) 'description': description,
    'price_kobo': priceKobo,
    if (imageUrl != null) 'image_url': imageUrl,
    'is_available': isAvailable,
  };
}

class CartItemConfiguration {
  final CartSelectedVariant? selectedVariant;
  final List<CartSelectedAddon> selectedAddons;

  const CartItemConfiguration({
    this.selectedVariant,
    this.selectedAddons = const [],
  });

  Map<String, dynamic> toJson() => {
    'selected_variant': selectedVariant?.toJson(),
    'selected_addons': selectedAddons.map((e) => e.toJson()).toList(),
  };
}

class CartSelectedVariant {
  final String variantId;
  final String name;
  final int priceDeltaKobo;
  final bool isDefault;

  const CartSelectedVariant({
    required this.variantId,
    required this.name,
    required this.priceDeltaKobo,
    required this.isDefault,
  });

  Map<String, dynamic> toJson() => {
    'variant_id': variantId,
    'name': name,
    'price_delta_kobo': priceDeltaKobo,
    'is_default': isDefault,
  };
}

class CartSelectedAddon {
  final String addonId;
  final String name;
  final int priceKobo;

  const CartSelectedAddon({
    required this.addonId,
    required this.name,
    required this.priceKobo,
  });

  Map<String, dynamic> toJson() => {
    'addon_id': addonId,
    'name': name,
    'price_kobo': priceKobo,
  };
}
