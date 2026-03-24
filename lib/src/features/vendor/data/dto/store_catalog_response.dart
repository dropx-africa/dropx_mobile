import 'package:json_annotation/json_annotation.dart';
import 'package:dropx_mobile/src/models/menu_item.dart';

part 'store_catalog_response.g.dart';

@JsonSerializable()
class StoreCatalogResponse {
  final Map<String, dynamic> store;
  final List<MenuItem> items;

  const StoreCatalogResponse({required this.store, required this.items});

  factory StoreCatalogResponse.fromJson(Map<String, dynamic> json) =>
      _$StoreCatalogResponseFromJson(json);
  Map<String, dynamic> toJson() => _$StoreCatalogResponseToJson(this);
}
