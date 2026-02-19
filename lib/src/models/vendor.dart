import 'package:json_annotation/json_annotation.dart';

part 'vendor.g.dart';

/// Vendor model representing a restaurant, pharmacy, retail store, or parcel service.
///
/// This is a shared model used across features (home, menu, cart, order).
/// Located in `models/` rather than a specific feature because multiple
/// features depend on it.
@JsonSerializable()
class Vendor {
  final String id;
  final String name;
  final String description;
  final double rating;
  @JsonKey(name: 'rating_count')
  final int ratingCount;
  @JsonKey(name: 'delivery_time')
  final String deliveryTime;
  @JsonKey(name: 'delivery_fee')
  final double deliveryFee;
  @JsonKey(name: 'image_url')
  final String imageUrl;
  @JsonKey(name: 'logo_url')
  final String logoUrl;
  final List<String> tags;
  @JsonKey(name: 'is_featured', defaultValue: false)
  final bool isFeatured;
  @JsonKey(name: 'is_fastest', defaultValue: false)
  final bool isFastest;
  @JsonKey(name: 'accuracy_badge')
  final String? accuracyBadge;
  final String category;

  const Vendor({
    required this.id,
    required this.name,
    required this.description,
    required this.rating,
    required this.ratingCount,
    required this.deliveryTime,
    required this.deliveryFee,
    required this.imageUrl,
    required this.logoUrl,
    required this.tags,
    required this.category,
    this.isFeatured = false,
    this.isFastest = false,
    this.accuracyBadge,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) => _$VendorFromJson(json);
  Map<String, dynamic> toJson() => _$VendorToJson(this);
}
