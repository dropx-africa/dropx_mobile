import 'package:json_annotation/json_annotation.dart';
import 'package:dropx_mobile/src/utils/currency_utils.dart';

part 'menu_item.g.dart';

@JsonSerializable()
class MenuItemVariant {
  @JsonKey(name: 'variant_id')
  final String variantId;
  final String name;
  @JsonKey(name: 'price_delta_kobo')
  final dynamic priceDeltaKobo;
  @JsonKey(name: 'is_default')
  final bool isDefault;
  final String status;

  double get priceDelta => CurrencyUtils.koboToNaira(priceDeltaKobo);

  const MenuItemVariant({
    required this.variantId,
    required this.name,
    this.priceDeltaKobo = 0,
    this.isDefault = false,
    this.status = 'ACTIVE',
  });

  factory MenuItemVariant.fromJson(Map<String, dynamic> json) =>
      _$MenuItemVariantFromJson(json);
  Map<String, dynamic> toJson() => _$MenuItemVariantToJson(this);
}

@JsonSerializable()
class MenuItemAddon {
  @JsonKey(name: 'addon_id')
  final String addonId;
  @JsonKey(name: 'group_name')
  final String groupName;
  @JsonKey(name: 'sort_order')
  final int sortOrder;
  final String name;
  @JsonKey(name: 'price_kobo')
  final dynamic priceKobo;
  @JsonKey(name: 'max_select')
  final int maxSelect;
  final bool required;
  final String status;

  double get price => CurrencyUtils.koboToNaira(priceKobo);

  const MenuItemAddon({
    required this.addonId,
    required this.groupName,
    this.sortOrder = 0,
    required this.name,
    this.priceKobo = 0,
    this.maxSelect = 1,
    this.required = false,
    this.status = 'ACTIVE',
  });

  factory MenuItemAddon.fromJson(Map<String, dynamic> json) =>
      _$MenuItemAddonFromJson(json);
  Map<String, dynamic> toJson() => _$MenuItemAddonToJson(this);
}

@JsonSerializable()
class MenuItem {
  @JsonKey(name: 'item_id')
  final String id;
  final String name;
  final String? description;
  @JsonKey(name: 'price_kobo')
  final dynamic priceKobo;

  double get price => CurrencyUtils.koboToNaira(priceKobo);

  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @JsonKey(name: 'prep_time')
  final String? prepTime;
  final List<String>? badges;
  final String? category;
  @JsonKey(name: 'vendor_id')
  final String? vendorId;
  @JsonKey(name: 'vendor_display_name')
  final String? vendorDisplayName;
  @JsonKey(name: 'is_available', defaultValue: true)
  final bool isAvailable;
  final List<MenuItemVariant>? variants;
  final List<MenuItemAddon>? addons;

  // ── Retail stock fields ──────────────────────────────────────────────────
  // stock_count: how many units remain. null means stock is not tracked
  // (food items). 0 means out of stock. >0 means in stock.
  @JsonKey(name: 'stock_count')
  final int? stockCount;

  // stock_status: backend-provided stock state string.
  // Known values: 'IN_STOCK', 'LOW_STOCK', 'OUT_OF_STOCK', null (not tracked)
  @JsonKey(name: 'stock_status')
  final String? stockStatus;
  // ────────────────────────────────────────────────────────────────────────

  const MenuItem({
    required this.id,
    required this.name,
    this.description,
    this.priceKobo = 0,
    this.imageUrl,
    this.prepTime,
    this.badges,
    this.category,
    this.vendorId,
    this.vendorDisplayName,
    this.isAvailable = true,
    this.variants,
    this.addons,
    this.stockCount,
    this.stockStatus,
  });

  /// True when stock is explicitly tracked AND exhausted.
  /// For food items where stock is not tracked, this is always false.
  bool get isOutOfStock =>
      stockCount != null && stockCount! <= 0 ||
          stockStatus == 'OUT_OF_STOCK';

  /// True when stock is tracked and running low (backend says LOW_STOCK
  /// or count is between 1 and 5 inclusive).
  bool get isLowStock =>
      stockStatus == 'LOW_STOCK' ||
          (stockCount != null && stockCount! > 0 && stockCount! <= 5);

  /// Whether this item can actually be added to cart.
  /// Combines isAvailable (vendor-level flag) with stock state.
  bool get canAddToCart => isAvailable && !isOutOfStock;

  factory MenuItem.fromJson(Map<String, dynamic> json) =>
      _$MenuItemFromJson(json);
  Map<String, dynamic> toJson() => _$MenuItemToJson(this);
}