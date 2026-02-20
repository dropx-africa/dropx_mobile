import 'package:json_annotation/json_annotation.dart';
import 'package:dropx_mobile/src/models/vendor_category.dart';
import 'package:dropx_mobile/src/utils/currency_utils.dart';

part 'menu_item.g.dart';

/// MenuItem model representing a product or service offered by a vendor.
///
/// This is a shared model used across features (menu, cart, order).
@JsonSerializable()
class MenuItem {
  @JsonKey(name: 'item_id')
  final String id;
  final String name;
  final String? description;
  @JsonKey(name: 'price_kobo')
  final dynamic priceKobo;

  double get price => CurrencyUtils.koboToNaira(priceKobo);

  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @JsonKey(name: 'prep_time')
  final String? prepTime;
  final List<String>? badges;
  @JsonKey(unknownEnumValue: VendorCategory.other)
  final VendorCategory? category;
  @JsonKey(name: 'vendor_id')
  final String? vendorId;
  @JsonKey(name: 'is_available', defaultValue: true)
  final bool isAvailable;

  const MenuItem({
    required this.id,
    required this.name,
    this.description,
    this.priceKobo = 0,
    this.imageUrl,
    this.prepTime,
    this.badges,
    this.category,
    this.vendorId,
    this.isAvailable = true,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) =>
      _$MenuItemFromJson(json);
  Map<String, dynamic> toJson() => _$MenuItemToJson(this);
}
