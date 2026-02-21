import 'package:json_annotation/json_annotation.dart';

part 'initialize_payment_response.g.dart';

/// Response DTO for `POST /payments/initialize`.
@JsonSerializable()
class InitializePaymentResponse {
  final bool ok;

  @JsonKey(name: 'authorization_url')
  final String authorizationUrl;

  final String reference;

  @JsonKey(name: 'payment_attempt_id')
  final String paymentAttemptId;

  @JsonKey(name: 'order_state')
  final String orderState;

  const InitializePaymentResponse({
    required this.ok,
    required this.authorizationUrl,
    required this.reference,
    required this.paymentAttemptId,
    required this.orderState,
  });

  factory InitializePaymentResponse.fromJson(Map<String, dynamic> json) =>
      _$InitializePaymentResponseFromJson(json);

  Map<String, dynamic> toJson() => _$InitializePaymentResponseToJson(this);
}
