// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'otp_challenge_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OtpChallengeResponse _$OtpChallengeResponseFromJson(
  Map<String, dynamic> json,
) => OtpChallengeResponse(
  otpChallengeId: json['otp_challenge_id'] as String,
  expiresAt: json['expires_at'] as String,
  nextResendAt: json['next_resend_at'] as String,
  attemptsRemaining: (json['attempts_remaining'] as num).toInt(),
  channelUsed: json['channel_used'] as String,
);

Map<String, dynamic> _$OtpChallengeResponseToJson(
  OtpChallengeResponse instance,
) => <String, dynamic>{
  'otp_challenge_id': instance.otpChallengeId,
  'expires_at': instance.expiresAt,
  'next_resend_at': instance.nextResendAt,
  'attempts_remaining': instance.attemptsRemaining,
  'channel_used': instance.channelUsed,
};
