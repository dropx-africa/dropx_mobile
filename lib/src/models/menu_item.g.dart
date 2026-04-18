// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MenuItemVariant _$MenuItemVariantFromJson(Map<String, dynamic> json) =>
    MenuItemVariant(
      variantId: json['variant_id'] as String,
      name: json['name'] as String,
      priceDeltaKobo: json['price_delta_kobo'] ?? 0,
      isDefault: json['is_default'] as bool? ?? false,
      status: json['status'] as String? ?? 'ACTIVE',
    );

Map<String, dynamic> _$MenuItemVariantToJson(MenuItemVariant instance) =>
    <String, dynamic>{
      'variant_id': instance.variantId,
      'name': instance.name,
      'price_delta_kobo': instance.priceDeltaKobo,
      'is_default': instance.isDefault,
      'status': instance.status,
    };

MenuItemAddon _$MenuItemAddonFromJson(Map<String, dynamic> json) =>
    MenuItemAddon(
      addonId: json['addon_id'] as String,
      groupName: json['group_name'] as String,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      name: json['name'] as String,
      priceKobo: json['price_kobo'] ?? 0,
      maxSelect: (json['max_select'] as num?)?.toInt() ?? 1,
      required: json['required'] as bool? ?? false,
      status: json['status'] as String? ?? 'ACTIVE',
    );

Map<String, dynamic> _$MenuItemAddonToJson(MenuItemAddon instance) =>
    <String, dynamic>{
      'addon_id': instance.addonId,
      'group_name': instance.groupName,
      'sort_order': instance.sortOrder,
      'name': instance.name,
      'price_kobo': instance.priceKobo,
      'max_select': instance.maxSelect,
      'required': instance.required,
      'status': instance.status,
    };

MenuItem _$MenuItemFromJson(Map<String, dynamic> json) => MenuItem(
  id: json['item_id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  priceKobo: json['price_kobo'] ?? 0,
  imageUrl: json['image_url'] as String?,
  prepTime: json['prep_time'] as String?,
  badges: (json['badges'] as List<dynamic>?)?.map((e) => e as String).toList(),
  category: json['category'] as String?,
  vendorId: json['vendor_id'] as String?,
  vendorDisplayName: json['vendor_display_name'] as String?,
  isAvailable: json['is_available'] as bool? ?? true,
  variants: (json['variants'] as List<dynamic>?)
      ?.map((e) => MenuItemVariant.fromJson(e as Map<String, dynamic>))
      .toList(),
  addons: (json['addons'] as List<dynamic>?)
      ?.map((e) => MenuItemAddon.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$MenuItemToJson(MenuItem instance) => <String, dynamic>{
  'item_id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'price_kobo': instance.priceKobo,
  'image_url': instance.imageUrl,
  'prep_time': instance.prepTime,
  'badges': instance.badges,
  'category': instance.category,
  'vendor_id': instance.vendorId,
  'vendor_display_name': instance.vendorDisplayName,
  'is_available': instance.isAvailable,
  'variants': instance.variants?.map((e) => e.toJson()).toList(),
  'addons': instance.addons?.map((e) => e.toJson()).toList(),
};
