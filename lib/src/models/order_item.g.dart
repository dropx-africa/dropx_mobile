// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderItem _$OrderItemFromJson(Map<String, dynamic> json) => OrderItem(
  orderItemId: json['order_item_id'] as String,
  orderId: json['order_id'] as String,
  name: json['name'] as String,
  qty: _parseInt(json['qty']),
  unitPriceKobo: _parseInt(json['unit_price_kobo']),
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$OrderItemToJson(OrderItem instance) => <String, dynamic>{
  'order_item_id': instance.orderItemId,
  'order_id': instance.orderId,
  'name': instance.name,
  'qty': instance.qty,
  'unit_price_kobo': instance.unitPriceKobo,
  'created_at': instance.createdAt,
};
