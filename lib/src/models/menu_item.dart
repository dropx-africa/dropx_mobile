import 'package:json_annotation/json_annotation.dart';

part 'menu_item.g.dart';

/// MenuItem model representing a product or service offered by a vendor.
///
/// This is a shared model used across features (menu, cart, order).
@JsonSerializable()
class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  @JsonKey(name: 'image_url')
  final String imageUrl;
  @JsonKey(name: 'prep_time')
  final String prepTime;
  @JsonKey(defaultValue: [])
  final List<String> badges;
  final String category;
  @JsonKey(name: 'vendor_id')
  final String vendorId;

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.prepTime,
    this.badges = const [],
    required this.category,
    required this.vendorId,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) =>
      _$MenuItemFromJson(json);
  Map<String, dynamic> toJson() => _$MenuItemToJson(this);
}
