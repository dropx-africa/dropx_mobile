// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
  orderId: json['order_id'] as String,
  customerUserId: json['customer_user_id'] as String?,
  vendorId: json['vendor_id'] as String?,
  zoneId: json['zone_id'] as String?,
  state: json['state'] as String,
  currency: json['currency'] as String?,
  totalAmountKobo: _parseToString(json['total_amount_kobo']),
  deliveryAddress: json['delivery_address'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
  'order_id': instance.orderId,
  'customer_user_id': instance.customerUserId,
  'vendor_id': instance.vendorId,
  'zone_id': instance.zoneId,
  'state': instance.state,
  'currency': instance.currency,
  'total_amount_kobo': instance.totalAmountKobo,
  'delivery_address': instance.deliveryAddress,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'items': instance.items,
};
