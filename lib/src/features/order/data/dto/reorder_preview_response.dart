import 'package:json_annotation/json_annotation.dart';

part 'reorder_preview_response.g.dart';

int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  if (value is double) return value.toInt();
  return 0;
}

@JsonSerializable()
class ReorderPreviewVendor {
  @JsonKey(name: 'vendor_id')
  final String vendorId;

  @JsonKey(name: 'display_name')
  final String displayName;

  @JsonKey(name: 'zone_id')
  final String? zoneId;

  @JsonKey(name: 'is_active')
  final bool isActive;

  @JsonKey(name: 'is_accepting_orders')
  final bool isAcceptingOrders;

  const ReorderPreviewVendor({
    required this.vendorId,
    required this.displayName,
    this.zoneId,
    this.isActive = true,
    this.isAcceptingOrders = true,
  });

  factory ReorderPreviewVendor.fromJson(Map<String, dynamic> json) =>
      _$ReorderPreviewVendorFromJson(json);
  Map<String, dynamic> toJson() => _$ReorderPreviewVendorToJson(this);
}

/// An order line the vendor's current catalog can still fulfill — matched
/// server-side by catalog identity, or by name for older orders.
@JsonSerializable()
class ReorderAvailableItem {
  @JsonKey(name: 'order_item_id')
  final String? orderItemId;

  /// The real, current catalog item id — safe to use directly in a new
  /// cart/estimate, unlike re-parsing the original order's own item data.
  @JsonKey(name: 'catalog_item_id')
  final String? catalogItemId;

  @JsonKey(name: 'previous_name')
  final String? previousName;

  @JsonKey(name: 'current_name')
  final String? currentName;

  @JsonKey(fromJson: _parseInt)
  final int qty;

  @JsonKey(name: 'previous_unit_price_kobo', fromJson: _parseInt)
  final int previousUnitPriceKobo;

  @JsonKey(name: 'current_unit_price_kobo', fromJson: _parseInt)
  final int currentUnitPriceKobo;

  @JsonKey(name: 'price_changed')
  final bool priceChanged;

  const ReorderAvailableItem({
    this.orderItemId,
    this.catalogItemId,
    this.previousName,
    this.currentName,
    required this.qty,
    required this.previousUnitPriceKobo,
    required this.currentUnitPriceKobo,
    this.priceChanged = false,
  });

  factory ReorderAvailableItem.fromJson(Map<String, dynamic> json) =>
      _$ReorderAvailableItemFromJson(json);
  Map<String, dynamic> toJson() => _$ReorderAvailableItemToJson(this);
}

/// An order line that can't be added back — the item no longer exists in
/// the vendor's current catalog.
@JsonSerializable()
class ReorderUnavailableItem {
  @JsonKey(name: 'order_item_id')
  final String? orderItemId;

  @JsonKey(name: 'previous_name')
  final String? previousName;

  @JsonKey(fromJson: _parseInt)
  final int qty;

  final String? reason;

  const ReorderUnavailableItem({
    this.orderItemId,
    this.previousName,
    required this.qty,
    this.reason,
  });

  factory ReorderUnavailableItem.fromJson(Map<String, dynamic> json) =>
      _$ReorderUnavailableItemFromJson(json);
  Map<String, dynamic> toJson() => _$ReorderUnavailableItemToJson(this);
}

@JsonSerializable()
class ReorderPreviewResponse {
  @JsonKey(name: 'order_id')
  final String orderId;

  @JsonKey(name: 'can_reorder')
  final bool canReorder;

  @JsonKey(name: 'blocking_reasons')
  final List<String> blockingReasons;

  final ReorderPreviewVendor vendor;

  @JsonKey(name: 'available_items')
  final List<ReorderAvailableItem> availableItems;

  @JsonKey(name: 'unavailable_items')
  final List<ReorderUnavailableItem> unavailableItems;

  const ReorderPreviewResponse({
    required this.orderId,
    required this.canReorder,
    this.blockingReasons = const [],
    required this.vendor,
    this.availableItems = const [],
    this.unavailableItems = const [],
  });

  factory ReorderPreviewResponse.fromJson(Map<String, dynamic> json) =>
      _$ReorderPreviewResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ReorderPreviewResponseToJson(this);
}
