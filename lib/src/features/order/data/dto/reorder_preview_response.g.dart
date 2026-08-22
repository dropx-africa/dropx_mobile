// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reorder_preview_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReorderPreviewVendor _$ReorderPreviewVendorFromJson(
  Map<String, dynamic> json,
) => ReorderPreviewVendor(
  vendorId: json['vendor_id'] as String,
  displayName: json['display_name'] as String,
  zoneId: json['zone_id'] as String?,
  isActive: json['is_active'] as bool? ?? true,
  isAcceptingOrders: json['is_accepting_orders'] as bool? ?? true,
);

Map<String, dynamic> _$ReorderPreviewVendorToJson(
  ReorderPreviewVendor instance,
) => <String, dynamic>{
  'vendor_id': instance.vendorId,
  'display_name': instance.displayName,
  'zone_id': instance.zoneId,
  'is_active': instance.isActive,
  'is_accepting_orders': instance.isAcceptingOrders,
};

ReorderAvailableItem _$ReorderAvailableItemFromJson(
  Map<String, dynamic> json,
) => ReorderAvailableItem(
  orderItemId: json['order_item_id'] as String?,
  catalogItemId: json['catalog_item_id'] as String?,
  previousName: json['previous_name'] as String?,
  currentName: json['current_name'] as String?,
  qty: _parseInt(json['qty']),
  previousUnitPriceKobo: _parseInt(json['previous_unit_price_kobo']),
  currentUnitPriceKobo: _parseInt(json['current_unit_price_kobo']),
  priceChanged: json['price_changed'] as bool? ?? false,
);

Map<String, dynamic> _$ReorderAvailableItemToJson(
  ReorderAvailableItem instance,
) => <String, dynamic>{
  'order_item_id': instance.orderItemId,
  'catalog_item_id': instance.catalogItemId,
  'previous_name': instance.previousName,
  'current_name': instance.currentName,
  'qty': instance.qty,
  'previous_unit_price_kobo': instance.previousUnitPriceKobo,
  'current_unit_price_kobo': instance.currentUnitPriceKobo,
  'price_changed': instance.priceChanged,
};

ReorderUnavailableItem _$ReorderUnavailableItemFromJson(
  Map<String, dynamic> json,
) => ReorderUnavailableItem(
  orderItemId: json['order_item_id'] as String?,
  previousName: json['previous_name'] as String?,
  qty: _parseInt(json['qty']),
  reason: json['reason'] as String?,
);

Map<String, dynamic> _$ReorderUnavailableItemToJson(
  ReorderUnavailableItem instance,
) => <String, dynamic>{
  'order_item_id': instance.orderItemId,
  'previous_name': instance.previousName,
  'qty': instance.qty,
  'reason': instance.reason,
};

ReorderPreviewResponse _$ReorderPreviewResponseFromJson(
  Map<String, dynamic> json,
) => ReorderPreviewResponse(
  orderId: json['order_id'] as String,
  canReorder: json['can_reorder'] as bool,
  blockingReasons:
      (json['blocking_reasons'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  vendor: ReorderPreviewVendor.fromJson(json['vendor'] as Map<String, dynamic>),
  availableItems:
      (json['available_items'] as List<dynamic>?)
          ?.map((e) => ReorderAvailableItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  unavailableItems:
      (json['unavailable_items'] as List<dynamic>?)
          ?.map(
            (e) => ReorderUnavailableItem.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
);

Map<String, dynamic> _$ReorderPreviewResponseToJson(
  ReorderPreviewResponse instance,
) => <String, dynamic>{
  'order_id': instance.orderId,
  'can_reorder': instance.canReorder,
  'blocking_reasons': instance.blockingReasons,
  'vendor': instance.vendor,
  'available_items': instance.availableItems,
  'unavailable_items': instance.unavailableItems,
};
