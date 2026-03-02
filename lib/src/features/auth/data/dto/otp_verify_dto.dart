import 'package:json_annotation/json_annotation.dart';

part 'otp_verify_dto.g.dart';

/// Request payload for the OTP verify endpoint.
@JsonSerializable(createFactory: false)
class OtpVerifyDto {
  @JsonKey(name: 'otp_challenge_id')
  final String otpChallengeId;

  final String otp;
  final String purpose;

  const OtpVerifyDto({
    required this.otpChallengeId,
    required this.otp,
    this.purpose = 'LOGIN',
  });

  Map<String, dynamic> toJson() => _$OtpVerifyDtoToJson(this);
}
