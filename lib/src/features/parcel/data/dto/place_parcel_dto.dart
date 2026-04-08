import 'package:json_annotation/json_annotation.dart';

part 'place_parcel_dto.g.dart';

@JsonSerializable(createFactory: false)
class PlaceParcelDto {
  @JsonKey(name: 'payment_method')
  final String paymentMethod;

  const PlaceParcelDto({required this.paymentMethod});

  Map<String, dynamic> toJson() => _$PlaceParcelDtoToJson(this);
}
