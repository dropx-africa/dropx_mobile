import 'package:json_annotation/json_annotation.dart';

part 'generate_payment_link_dto.g.dart';

@JsonSerializable(createFactory: false)
class GeneratePaymentLinkDto {
  @JsonKey(name: 'ttl_minutes')
  final int ttlMinutes;

  const GeneratePaymentLinkDto({required this.ttlMinutes});

  Map<String, dynamic> toJson() => _$GeneratePaymentLinkDtoToJson(this);
}
