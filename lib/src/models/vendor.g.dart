// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vendor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Vendor _$VendorFromJson(Map<String, dynamic> json) => Vendor(
  id: json['vendor_id'] as String,
  name: json['display_name'] as String,
  description: json['description'] as String?,
  rating: (json['rating'] as num?)?.toDouble(),
  ratingCount: (json['rating_count'] as num?)?.toInt(),
  deliveryTime: json['delivery_time'] as String?,
  deliveryFee: (json['delivery_fee'] as num?)?.toDouble(),
  imageUrl: json['image_url'] as String?,
  logoUrl: json['logo_url'] as String?,
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
  category: $enumDecodeNullable(
    _$VendorCategoryEnumMap,
    json['category'],
    unknownValue: VendorCategory.other,
  ),
  isFeatured: json['is_featured'] as bool? ?? false,
  isFastest: json['is_fastest'] as bool? ?? false,
  isActive: json['is_active'] as bool? ?? true,
  zoneId: json['zone_id'] as String? ?? '',
  accuracyBadge: json['accuracy_badge'] as String?,
  ownerUserId: json['owner_user_id'] as String?,
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$VendorToJson(Vendor instance) => <String, dynamic>{
  'vendor_id': instance.id,
  'display_name': instance.name,
  'description': instance.description,
  'rating': instance.rating,
  'rating_count': instance.ratingCount,
  'delivery_time': instance.deliveryTime,
  'delivery_fee': instance.deliveryFee,
  'image_url': instance.imageUrl,
  'logo_url': instance.logoUrl,
  'tags': instance.tags,
  'is_featured': instance.isFeatured,
  'is_fastest': instance.isFastest,
  'is_active': instance.isActive,
  'zone_id': instance.zoneId,
  'accuracy_badge': instance.accuracyBadge,
  'category': _$VendorCategoryEnumMap[instance.category],
  'owner_user_id': instance.ownerUserId,
  'created_at': instance.createdAt,
};

const _$VendorCategoryEnumMap = {
  VendorCategory.food: 'food',
  VendorCategory.pharmacy: 'pharmacy',
  VendorCategory.parcel: 'parcel',
  VendorCategory.retail: 'retail',
  VendorCategory.other: 'other',
};
