import 'package:json_annotation/json_annotation.dart';

part 'initialize_pay_link_response.g.dart';

@JsonSerializable()
class InitializePayLinkResponse {
  final bool ok;

  @JsonKey(name: 'authorization_url')
  final String authorizationUrl;

  final String reference;

  @JsonKey(name: 'payment_attempt_id')
  final String paymentAttemptId;

  @JsonKey(name: 'order_state')
  final String orderState;

  const InitializePayLinkResponse({
    required this.ok,
    required this.authorizationUrl,
    required this.reference,
    required this.paymentAttemptId,
    required this.orderState,
  });

  factory InitializePayLinkResponse.fromJson(Map<String, dynamic> json) =>
      _$InitializePayLinkResponseFromJson(json);

  Map<String, dynamic> toJson() => _$InitializePayLinkResponseToJson(this);
}
