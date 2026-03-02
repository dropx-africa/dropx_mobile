// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'estimate_order_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EstimateOrderRequest _$EstimateOrderRequestFromJson(
  Map<String, dynamic> json,
) => EstimateOrderRequest(
  zoneId: json['zone_id'] as String,
  vendorId: json['vendor_id'] as String,
  items: (json['items'] as List<dynamic>)
      .map((e) => EstimateOrderItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  deliveryAddressId: json['delivery_address_id'] as String?,
  deliveryLat: (json['delivery_lat'] as num).toDouble(),
  deliveryLng: (json['delivery_lng'] as num).toDouble(),
  serviceTier: json['service_tier'] as String,
);

Map<String, dynamic> _$EstimateOrderRequestToJson(
  EstimateOrderRequest instance,
) => <String, dynamic>{
  'zone_id': instance.zoneId,
  'vendor_id': instance.vendorId,
  'items': instance.items.map((e) => e.toJson()).toList(),
  'delivery_address_id': instance.deliveryAddressId,
  'delivery_lat': instance.deliveryLat,
  'delivery_lng': instance.deliveryLng,
  'service_tier': instance.serviceTier,
};

EstimateOrderItem _$EstimateOrderItemFromJson(Map<String, dynamic> json) =>
    EstimateOrderItem(
      itemId: json['item_id'] as String,
      name: json['name'] as String,
      qty: (json['qty'] as num).toInt(),
      unitPriceKobo: (json['unit_price_kobo'] as num).toInt(),
    );

Map<String, dynamic> _$EstimateOrderItemToJson(EstimateOrderItem instance) =>
    <String, dynamic>{
      'item_id': instance.itemId,
      'name': instance.name,
      'qty': instance.qty,
      'unit_price_kobo': instance.unitPriceKobo,
    };
