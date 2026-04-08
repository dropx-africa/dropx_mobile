// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServerCartResponse _$ServerCartResponseFromJson(Map<String, dynamic> json) =>
    ServerCartResponse(
      ok: json['ok'] as bool,
      data: ServerCartData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ServerCartResponseToJson(
  ServerCartResponse instance,
) => <String, dynamic>{'ok': instance.ok, 'data': instance.data.toJson()};

ServerCartData _$ServerCartDataFromJson(Map<String, dynamic> json) =>
    ServerCartData(
      vendorId: json['vendor_id'] as String?,
      zoneId: json['zone_id'] as String?,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => ServerCartItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ServerCartDataToJson(ServerCartData instance) =>
    <String, dynamic>{
      'vendor_id': instance.vendorId,
      'zone_id': instance.zoneId,
      'items': instance.items.map((e) => e.toJson()).toList(),
    };

ServerCartItem _$ServerCartItemFromJson(Map<String, dynamic> json) =>
    ServerCartItem(
      itemId: json['item_id'] as String,
      name: json['name'] as String,
      qty: (json['qty'] as num).toInt(),
      unitPriceKobo: (json['unit_price_kobo'] as num).toInt(),
    );

Map<String, dynamic> _$ServerCartItemToJson(ServerCartItem instance) =>
    <String, dynamic>{
      'item_id': instance.itemId,
      'name': instance.name,
      'qty': instance.qty,
      'unit_price_kobo': instance.unitPriceKobo,
    };

Map<String, dynamic> _$CartSyncDtoToJson(CartSyncDto instance) =>
    <String, dynamic>{
      'vendor_id': instance.vendorId,
      'zone_id': instance.zoneId,
      'items': instance.items.map((e) => e.toJson()).toList(),
    };

Map<String, dynamic> _$CartSyncItemToJson(CartSyncItem instance) =>
    <String, dynamic>{
      'item_id': instance.itemId,
      'name': instance.name,
      'qty': instance.qty,
      'unit_price_kobo': instance.unitPriceKobo,
    };
