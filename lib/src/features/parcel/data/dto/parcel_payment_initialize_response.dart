import 'package:json_annotation/json_annotation.dart';

part 'parcel_payment_initialize_response.g.dart';

@JsonSerializable(explicitToJson: true)
class ParcelPaymentInitializeResponse {
  final bool ok;
  final ParcelPaymentInitializeData data;

  const ParcelPaymentInitializeResponse({required this.ok, required this.data});

  factory ParcelPaymentInitializeResponse.fromJson(Map<String, dynamic> json) =>
      _$ParcelPaymentInitializeResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ParcelPaymentInitializeResponseToJson(this);
}

@JsonSerializable()
class ParcelPaymentInitializeData {
  @JsonKey(name: 'authorization_url')
  final String authorizationUrl;

  final String reference;

  @JsonKey(name: 'payment_attempt_id')
  final String? paymentAttemptId;

  const ParcelPaymentInitializeData({
    required this.authorizationUrl,
    required this.reference,
    this.paymentAttemptId,
  });

  factory ParcelPaymentInitializeData.fromJson(Map<String, dynamic> json) =>
      _$ParcelPaymentInitializeDataFromJson(json);

  Map<String, dynamic> toJson() => _$ParcelPaymentInitializeDataToJson(this);
}
