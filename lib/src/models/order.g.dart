// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
  id: json['id'] as String,
  vendorName: json['vendor_name'] as String,
  vendorLogo: json['vendor_logo'] as String,
  itemsSummary: json['items_summary'] as String,
  date: json['date'] as String,
  price: (json['price'] as num).toDouble(),
  status: json['status'] as String,
);

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
  'id': instance.id,
  'vendor_name': instance.vendorName,
  'vendor_logo': instance.vendorLogo,
  'items_summary': instance.itemsSummary,
  'date': instance.date,
  'price': instance.price,
  'status': instance.status,
};
