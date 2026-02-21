import 'package:json_annotation/json_annotation.dart';

part 'generate_payment_link_response.g.dart';

@JsonSerializable()
class GeneratePaymentLinkResponse {
  final bool ok;

  @JsonKey(name: 'payment_link_id')
  final String paymentLinkId;

  @JsonKey(name: 'expires_at')
  final String expiresAt;

  final String token;
  final String note;

  const GeneratePaymentLinkResponse({
    required this.ok,
    required this.paymentLinkId,
    required this.expiresAt,
    required this.token,
    required this.note,
  });

  factory GeneratePaymentLinkResponse.fromJson(Map<String, dynamic> json) =>
      _$GeneratePaymentLinkResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GeneratePaymentLinkResponseToJson(this);
}
