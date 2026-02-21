import 'package:json_annotation/json_annotation.dart';

part 'place_order_response.g.dart';

@JsonSerializable()
class PlaceOrderResponse {
  @JsonKey(name: 'payment_method')
  final String paymentMethod;

  const PlaceOrderResponse({required this.paymentMethod});

  factory PlaceOrderResponse.fromJson(Map<String, dynamic> json) =>
      _$PlaceOrderResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PlaceOrderResponseToJson(this);
}
