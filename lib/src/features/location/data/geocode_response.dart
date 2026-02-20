import 'package:json_annotation/json_annotation.dart';
import 'package:dropx_mobile/src/features/location/data/geocode_result.dart';

part 'geocode_response.g.dart';

@JsonSerializable()
class GeocodeResponse {
  final bool ok;
  final String? query;
  final List<GeocodeResult> results;

  const GeocodeResponse({
    required this.ok,
    this.query,
    this.results = const [],
  });

  factory GeocodeResponse.fromJson(Map<String, dynamic> json) =>
      _$GeocodeResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GeocodeResponseToJson(this);
}
