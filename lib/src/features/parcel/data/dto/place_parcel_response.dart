import 'package:json_annotation/json_annotation.dart';

part 'place_parcel_response.g.dart';

@JsonSerializable(explicitToJson: true)
class PlaceParcelResponse {
  final bool ok;
  final PlaceParcelData data;

  const PlaceParcelResponse({required this.ok, required this.data});

  factory PlaceParcelResponse.fromJson(Map<String, dynamic> json) =>
      _$PlaceParcelResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PlaceParcelResponseToJson(this);
}

@JsonSerializable()
class PlaceParcelData {
  @JsonKey(name: 'parcel_id')
  final String parcelId;

  final String state;

  @JsonKey(name: 'payment_method')
  final String? paymentMethod;

  @JsonKey(name: 'total_kobo')
  final int? totalKobo;

  const PlaceParcelData({
    required this.parcelId,
    required this.state,
    this.paymentMethod,
    this.totalKobo,
  });

  factory PlaceParcelData.fromJson(Map<String, dynamic> json) =>
      _$PlaceParcelDataFromJson(json);

  Map<String, dynamic> toJson() => _$PlaceParcelDataToJson(this);
}
