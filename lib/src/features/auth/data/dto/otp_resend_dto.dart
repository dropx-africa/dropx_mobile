import 'package:json_annotation/json_annotation.dart';

part 'otp_resend_dto.g.dart';

/// Request payload for the OTP resend endpoint.
@JsonSerializable(createFactory: false)
class OtpResendDto {
  @JsonKey(name: 'otp_challenge_id')
  final String otpChallengeId;

  final String purpose;
  final String channel;

  const OtpResendDto({
    required this.otpChallengeId,
    this.purpose = 'LOGIN',
    this.channel = 'sms',
  });

  Map<String, dynamic> toJson() => _$OtpResendDtoToJson(this);
}
