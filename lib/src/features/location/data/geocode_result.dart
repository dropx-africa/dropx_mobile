import 'package:json_annotation/json_annotation.dart';

part 'geocode_result.g.dart';

@JsonSerializable()
class GeocodeResult {
  @JsonKey(name: 'place_id')
  final String placeId;

  @JsonKey(name: 'formatted_address')
  final String formattedAddress;

  final double lat;
  final double lng;
  final String? provider;

  const GeocodeResult({
    required this.placeId,
    required this.formattedAddress,
    required this.lat,
    required this.lng,
    this.provider,
  });

  factory GeocodeResult.fromJson(Map<String, dynamic> json) =>
      _$GeocodeResultFromJson(json);

  Map<String, dynamic> toJson() => _$GeocodeResultToJson(this);
}
