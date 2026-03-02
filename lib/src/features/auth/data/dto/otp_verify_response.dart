import 'package:json_annotation/json_annotation.dart';

part 'otp_verify_response.g.dart';

/// Response model for the OTP verify endpoint.
@JsonSerializable()
class OtpVerifyResponse {
  @JsonKey(name: 'user_id')
  final String userId;

  @JsonKey(name: 'access_token')
  final String accessToken;

  @JsonKey(name: 'refresh_token')
  final String refreshToken;

  @JsonKey(name: 'token_type')
  final String tokenType;

  @JsonKey(name: 'expires_in')
  final int expiresIn;

  @JsonKey(name: 'otp_challenge_id')
  final String otpChallengeId;

  @JsonKey(name: 'attempts_remaining')
  final int attemptsRemaining;

  const OtpVerifyResponse({
    required this.userId,
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.otpChallengeId,
    required this.attemptsRemaining,
  });

  factory OtpVerifyResponse.fromJson(Map<String, dynamic> json) =>
      _$OtpVerifyResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OtpVerifyResponseToJson(this);
}
