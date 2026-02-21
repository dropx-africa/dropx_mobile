import 'package:json_annotation/json_annotation.dart';

part 'initialize_pay_link_dto.g.dart';

@JsonSerializable(createFactory: false)
class InitializePayLinkDto {
  final String provider;

  @JsonKey(name: 'payer_email')
  final String payerEmail;

  const InitializePayLinkDto({
    required this.provider,
    required this.payerEmail,
  });

  Map<String, dynamic> toJson() => _$InitializePayLinkDtoToJson(this);
}
