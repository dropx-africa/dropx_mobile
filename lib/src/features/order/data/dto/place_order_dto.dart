import 'package:json_annotation/json_annotation.dart';

part 'place_order_dto.g.dart';

@JsonSerializable(createFactory: false)
class PlaceOrderDto {
  @JsonKey(name: 'payment_method')
  final String paymentMethod;

  const PlaceOrderDto({required this.paymentMethod});

  Map<String, dynamic> toJson() => _$PlaceOrderDtoToJson(this);
}
