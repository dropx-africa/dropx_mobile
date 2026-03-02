import 'package:json_annotation/json_annotation.dart';
import 'package:dropx_mobile/src/models/vendor.dart';
import 'package:dropx_mobile/src/models/menu_item.dart';

part 'search_response.g.dart';

@JsonSerializable(explicitToJson: true)
class SearchData {
  final List<Vendor> vendors;
  final List<MenuItem> items;

  @JsonKey(name: 'next_cursor')
  final String? nextCursor;

  const SearchData({
    required this.vendors,
    required this.items,
    this.nextCursor,
  });

  factory SearchData.fromJson(Map<String, dynamic> json) =>
      _$SearchDataFromJson(json);

  Map<String, dynamic> toJson() => _$SearchDataToJson(this);
}
