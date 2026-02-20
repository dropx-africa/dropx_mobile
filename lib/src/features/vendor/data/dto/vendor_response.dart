import 'package:json_annotation/json_annotation.dart';
import 'package:dropx_mobile/src/models/vendor.dart';

part 'vendor_response.g.dart';

@JsonSerializable()
class VendorResponse {
  final bool ok;
  final Vendor vendor;

  const VendorResponse({required this.ok, required this.vendor});

  factory VendorResponse.fromJson(Map<String, dynamic> json) =>
      _$VendorResponseFromJson(json);

  Map<String, dynamic> toJson() => _$VendorResponseToJson(this);
}
