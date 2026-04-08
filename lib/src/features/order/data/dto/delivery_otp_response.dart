import 'package:json_annotation/json_annotation.dart';

part 'delivery_otp_response.g.dart';

@JsonSerializable(explicitToJson: true)
class DeliveryOtpResponse {
  final bool ok;
  final DeliveryOtpData data;

  const DeliveryOtpResponse({required this.ok, required this.data});

  factory DeliveryOtpResponse.fromJson(Map<String, dynamic> json) =>
      _$DeliveryOtpResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DeliveryOtpResponseToJson(this);
}

@JsonSerializable()
class DeliveryOtpData {
  @JsonKey(name: 'order_id')
  final String orderId;

  final String state;

  @JsonKey(name: 'delivery_otp')
  final String? deliveryOtp;

  @JsonKey(name: 'delivery_otp_available')
  final bool deliveryOtpAvailable;

  @JsonKey(name: 'issued_at')
  final String? issuedAt;

  @JsonKey(name: 'expires_at')
  final String? expiresAt;

  @JsonKey(name: 'channel_used')
  final String? channelUsed;

  @JsonKey(name: 'delivery_status')
  final String? deliveryStatus;

  @JsonKey(name: 'attempts_remaining')
  final int? attemptsRemaining;

  const DeliveryOtpData({
    required this.orderId,
    required this.state,
    this.deliveryOtp,
    required this.deliveryOtpAvailable,
    this.issuedAt,
    this.expiresAt,
    this.channelUsed,
    this.deliveryStatus,
    this.attemptsRemaining,
  });

  factory DeliveryOtpData.fromJson(Map<String, dynamic> json) =>
      _$DeliveryOtpDataFromJson(json);

  Map<String, dynamic> toJson() => _$DeliveryOtpDataToJson(this);
}
