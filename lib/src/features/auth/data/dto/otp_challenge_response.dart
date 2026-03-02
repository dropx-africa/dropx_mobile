import 'package:json_annotation/json_annotation.dart';

part 'otp_challenge_response.g.dart';

/// Response model for OTP request and resend endpoints.
@JsonSerializable()
class OtpChallengeResponse {
  @JsonKey(name: 'otp_challenge_id')
  final String otpChallengeId;

  @JsonKey(name: 'expires_at')
  final String expiresAt;

  @JsonKey(name: 'next_resend_at')
  final String nextResendAt;

  @JsonKey(name: 'attempts_remaining')
  final int attemptsRemaining;

  @JsonKey(name: 'channel_used')
  final String channelUsed;

  const OtpChallengeResponse({
    required this.otpChallengeId,
    required this.expiresAt,
    required this.nextResendAt,
    required this.attemptsRemaining,
    required this.channelUsed,
  });

  factory OtpChallengeResponse.fromJson(Map<String, dynamic> json) =>
      _$OtpChallengeResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OtpChallengeResponseToJson(this);
}
