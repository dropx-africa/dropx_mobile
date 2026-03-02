// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FeedItem _$FeedItemFromJson(Map<String, dynamic> json) => FeedItem(
  vendorId: json['vendor_id'] as String,
  displayName: json['display_name'] as String,
  rating: (json['rating'] as num?)?.toDouble(),
  etaMinutes: (json['eta_minutes'] as num?)?.toInt(),
  deliveryFeeKobo: json['delivery_fee_kobo'] as String?,
  distanceKm: (json['distance_km'] as num?)?.toDouble(),
  categories: (json['categories'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  isOpen: json['is_open'] as bool?,
  minOrderKobo: json['min_order_kobo'] as String?,
);

Map<String, dynamic> _$FeedItemToJson(FeedItem instance) => <String, dynamic>{
  'vendor_id': instance.vendorId,
  'display_name': instance.displayName,
  'rating': instance.rating,
  'eta_minutes': instance.etaMinutes,
  'delivery_fee_kobo': instance.deliveryFeeKobo,
  'distance_km': instance.distanceKm,
  'categories': instance.categories,
  'is_open': instance.isOpen,
  'min_order_kobo': instance.minOrderKobo,
};
