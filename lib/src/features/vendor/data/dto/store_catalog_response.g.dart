// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_catalog_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoreCatalogResponse _$StoreCatalogResponseFromJson(
  Map<String, dynamic> json,
) => StoreCatalogResponse(
  store: json['store'] as Map<String, dynamic>,
  items: (json['items'] as List<dynamic>)
      .map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$StoreCatalogResponseToJson(
  StoreCatalogResponse instance,
) => <String, dynamic>{'store': instance.store, 'items': instance.items};
