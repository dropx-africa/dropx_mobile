// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MenuItem _$MenuItemFromJson(Map<String, dynamic> json) => MenuItem(
  id: json['item_id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  priceKobo: json['price_kobo'] ?? 0,
  imageUrl: json['image_url'] as String?,
  prepTime: json['prep_time'] as String?,
  badges: (json['badges'] as List<dynamic>?)?.map((e) => e as String).toList(),
  category: $enumDecodeNullable(
    _$VendorCategoryEnumMap,
    json['category'],
    unknownValue: VendorCategory.other,
  ),
  vendorId: json['vendor_id'] as String?,
  isAvailable: json['is_available'] as bool? ?? true,
);

Map<String, dynamic> _$MenuItemToJson(MenuItem instance) => <String, dynamic>{
  'item_id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'price_kobo': instance.priceKobo,
  'image_url': instance.imageUrl,
  'prep_time': instance.prepTime,
  'badges': instance.badges,
  'category': _$VendorCategoryEnumMap[instance.category],
  'vendor_id': instance.vendorId,
  'is_available': instance.isAvailable,
};

const _$VendorCategoryEnumMap = {
  VendorCategory.food: 'food',
  VendorCategory.pharmacy: 'pharmacy',
  VendorCategory.parcel: 'parcel',
  VendorCategory.retail: 'retail',
  VendorCategory.other: 'other',
};
