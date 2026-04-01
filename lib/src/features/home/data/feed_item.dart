import 'package:json_annotation/json_annotation.dart';

part 'feed_item.g.dart';

@JsonSerializable()
class FeedItem {
  @JsonKey(name: 'vendor_id')
  final String vendorId;

  @JsonKey(name: 'display_name')
  final String displayName;

  final double? rating;

  @JsonKey(name: 'eta_minutes')
  final int? etaMinutes;

  @JsonKey(name: 'delivery_fee_kobo')
  final String? deliveryFeeKobo;

  @JsonKey(name: 'distance_km')
  final double? distanceKm;

  final List<String>? categories;

  @JsonKey(name: 'is_open')
  final bool? isOpen;

  @JsonKey(name: 'min_order_kobo')
  final String? minOrderKobo;

  @JsonKey(name: 'image_url')
  final String? imageUrl;

  const FeedItem({
    required this.vendorId,
    required this.displayName,
    this.rating,
    this.etaMinutes,
    this.deliveryFeeKobo,
    this.distanceKm,
    this.categories,
    this.isOpen,
    this.minOrderKobo,
    this.imageUrl,
  });

  /// Delivery fee in Naira (kobo → naira).
  double get deliveryFeeNaira {
    if (deliveryFeeKobo == null) return 0;
    return (double.tryParse(deliveryFeeKobo!) ?? 0) / 100;
  }

  /// Min order in Naira.
  double get minOrderNaira {
    if (minOrderKobo == null) return 0;
    return (double.tryParse(minOrderKobo!) ?? 0) / 100;
  }

  factory FeedItem.fromJson(Map<String, dynamic> json) =>
      _$FeedItemFromJson(json);

  Map<String, dynamic> toJson() => _$FeedItemToJson(this);
}
