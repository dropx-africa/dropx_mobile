import 'package:json_annotation/json_annotation.dart';
import 'package:dropx_mobile/src/models/vendor_category.dart';

part 'vendor.g.dart';

/// Vendor model representing a restaurant, pharmacy, retail store, or parcel service.
///
/// This is a shared model used across features (home, menu, cart, order).
/// Located in `models/` rather than a specific feature because multiple
/// features depend on it.
@JsonSerializable()
class Vendor {
  @JsonKey(name: 'vendor_id')
  final String id;
  @JsonKey(name: 'display_name')
  final String name;
  final String? description;
  final double? rating;
  @JsonKey(name: 'rating_count')
  final int? ratingCount;
  @JsonKey(name: 'delivery_time')
  final String? deliveryTime;
  @JsonKey(name: 'delivery_fee')
  final double? deliveryFee;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @JsonKey(name: 'logo_url')
  final String? logoUrl;
  final List<String>? tags;
  @JsonKey(name: 'is_featured', defaultValue: false)
  final bool isFeatured;
  @JsonKey(name: 'is_fastest', defaultValue: false)
  final bool isFastest;
  @JsonKey(name: 'is_active', defaultValue: true)
  final bool isActive;
  @JsonKey(name: 'zone_id', defaultValue: '')
  final String zoneId;
  @JsonKey(name: 'accuracy_badge')
  final String? accuracyBadge;
  @JsonKey(unknownEnumValue: VendorCategory.other)
  final VendorCategory? category;
  @JsonKey(name: 'owner_user_id')
  final String? ownerUserId;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'eta_minutes')
  final int? etaMinutes;
  @JsonKey(name: 'delivery_fee_kobo')
  final String? deliveryFeeKobo;
  @JsonKey(name: 'distance_km')
  final double? distanceKm;
  @JsonKey(name: 'is_open')
  final bool? isOpen;
  @JsonKey(name: 'cover_image_url')
  final String? coverImageUrl;

  /// Delivery fee in Naira (kobo → naira).
  double get deliveryFeeNaira {
    if (deliveryFeeKobo == null) return 0;
    return (double.tryParse(deliveryFeeKobo!) ?? 0) / 100;
  }

  const Vendor({
    required this.id,
    required this.name,
    this.description,
    this.rating,
    this.ratingCount,
    this.deliveryTime,
    this.deliveryFee,
    this.imageUrl,
    this.logoUrl,
    this.coverImageUrl,
    this.tags,
    this.category,
    this.isFeatured = false,
    this.isFastest = false,
    this.isActive = true,
    this.zoneId = '',
    this.accuracyBadge,
    this.ownerUserId,
    this.createdAt,
    this.etaMinutes,
    this.deliveryFeeKobo,
    this.distanceKm,
    this.isOpen,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) => _$VendorFromJson(json);
  Map<String, dynamic> toJson() => _$VendorToJson(this);
}
