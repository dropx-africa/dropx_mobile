/// Response model for OTP request and resend endpoints.
///
/// Matches the actual API shape:
/// {
///   "ok": true,
///   "otp_challenge_id": "otp_ch_123",
///   "purpose": "LOGIN",
///   "channel": "sms",
///   "expires_at": "2026-03-27T20:10:00.000Z",
///   "resend_available_at": "2026-03-27T20:06:00.000Z"
/// }
class OtpChallengeResponse {
  final bool ok;
  final String otpChallengeId;
  final String? purpose;
  final String? channel;
  final String expiresAt;
  final String? resendAvailableAt;
  final int? attemptsRemaining;
  final String? recipientHint;

  const OtpChallengeResponse({
    required this.ok,
    required this.otpChallengeId,
    this.purpose,
    this.channel,
    required this.expiresAt,
    this.resendAvailableAt,
    this.attemptsRemaining,
    this.recipientHint,
  });

  factory OtpChallengeResponse.fromJson(Map<String, dynamic> json) {
    return OtpChallengeResponse(
      ok: json['ok'] as bool? ?? true,
      otpChallengeId: json['otp_challenge_id'] as String,
      purpose: json['purpose'] as String?,
      channel: (json['channel_used'] ?? json['channel']) as String?,
      expiresAt: json['expires_at'] as String,
      resendAvailableAt: (json['next_resend_at'] ?? json['resend_available_at']) as String?,
      attemptsRemaining: (json['attempts_remaining'] as num?)?.toInt(),
      recipientHint: json['recipient_hint'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'ok': ok,
    'otp_challenge_id': otpChallengeId,
    if (purpose != null) 'purpose': purpose,
    if (channel != null) 'channel_used': channel,
    'expires_at': expiresAt,
    if (resendAvailableAt != null) 'resend_available_at': resendAvailableAt,
    if (attemptsRemaining != null) 'attempts_remaining': attemptsRemaining,
    if (recipientHint != null) 'recipient_hint': recipientHint,
  };
}
