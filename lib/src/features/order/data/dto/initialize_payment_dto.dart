import 'package:json_annotation/json_annotation.dart';

part 'initialize_payment_dto.g.dart';

/// Request payload for `POST /payments/initialize`.
@JsonSerializable(createFactory: false)
class InitializePaymentDto {
  @JsonKey(name: 'order_id')
  final String orderId;

  final String provider;

  const InitializePaymentDto({
    required this.orderId,
    this.provider = 'paystack',
  });

  Map<String, dynamic> toJson() => _$InitializePaymentDtoToJson(this);
}
