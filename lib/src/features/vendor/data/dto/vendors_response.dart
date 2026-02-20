import 'package:json_annotation/json_annotation.dart';
import 'package:dropx_mobile/src/models/vendor.dart';

part 'vendors_response.g.dart';

@JsonSerializable()
class VendorsResponse {
  final bool ok;
  final List<Vendor> vendors;

  const VendorsResponse({required this.ok, required this.vendors});

  factory VendorsResponse.fromJson(Map<String, dynamic> json) =>
      _$VendorsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$VendorsResponseToJson(this);
}
