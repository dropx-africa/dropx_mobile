// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vendor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Vendor _$VendorFromJson(Map<String, dynamic> json) => Vendor(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  rating: (json['rating'] as num).toDouble(),
  ratingCount: (json['rating_count'] as num).toInt(),
  deliveryTime: json['delivery_time'] as String,
  deliveryFee: (json['delivery_fee'] as num).toDouble(),
  imageUrl: json['image_url'] as String,
  logoUrl: json['logo_url'] as String,
  tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
  category: json['category'] as String,
  isFeatured: json['is_featured'] as bool? ?? false,
  isFastest: json['is_fastest'] as bool? ?? false,
  accuracyBadge: json['accuracy_badge'] as String?,
);

Map<String, dynamic> _$VendorToJson(Vendor instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
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
  'accuracy_badge': instance.accuracyBadge,
  'category': instance.category,
};
