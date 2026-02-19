// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MenuItem _$MenuItemFromJson(Map<String, dynamic> json) => MenuItem(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  price: (json['price'] as num).toDouble(),
  imageUrl: json['image_url'] as String,
  prepTime: json['prep_time'] as String,
  badges:
      (json['badges'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
  category: json['category'] as String,
  vendorId: json['vendor_id'] as String,
);

Map<String, dynamic> _$MenuItemToJson(MenuItem instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'price': instance.price,
  'image_url': instance.imageUrl,
  'prep_time': instance.prepTime,
  'badges': instance.badges,
  'category': instance.category,
  'vendor_id': instance.vendorId,
};
