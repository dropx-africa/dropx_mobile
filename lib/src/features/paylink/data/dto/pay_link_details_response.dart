import 'package:json_annotation/json_annotation.dart';

part 'pay_link_details_response.g.dart';

@JsonSerializable()
class PayLinkDetailsResponse {
  final bool ok;

  @JsonKey(name: 'order_id')
  final String orderId;

  @JsonKey(name: 'amount_kobo')
  final String amountKobo;

  final String currency;

  @JsonKey(name: 'expires_at')
  final String expiresAt;

  final String status;

  const PayLinkDetailsResponse({
    required this.ok,
    required this.orderId,
    required this.amountKobo,
    required this.currency,
    required this.expiresAt,
    required this.status,
  });

  factory PayLinkDetailsResponse.fromJson(Map<String, dynamic> json) =>
      _$PayLinkDetailsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PayLinkDetailsResponseToJson(this);
}
