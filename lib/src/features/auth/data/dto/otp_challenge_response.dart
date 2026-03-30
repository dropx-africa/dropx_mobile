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
  final String purpose;
  final String channel;
  final String expiresAt;

  /// ISO-8601 timestamp after which the client may request a resend.
  /// Formerly `next_resend_at` — actual API field is `resend_available_at`.
  final String? resendAvailableAt;

  /// Not returned by the current API — kept nullable for forward compat.
  final int? attemptsRemaining;

  const OtpChallengeResponse({
    required this.ok,
    required this.otpChallengeId,
    required this.purpose,
    required this.channel,
    required this.expiresAt,
    this.resendAvailableAt,
    this.attemptsRemaining,
  });

  factory OtpChallengeResponse.fromJson(Map<String, dynamic> json) {
    return OtpChallengeResponse(
      ok: json['ok'] as bool? ?? true,
      otpChallengeId: json['otp_challenge_id'] as String,
      purpose: json['purpose'] as String,
      channel: (json['channel_used']) as String,
      expiresAt: json['expires_at'] as String,
      resendAvailableAt: (json['next_resend_at'] ?? json['resend_available_at']) as String?,
      attemptsRemaining: (json['attempts_remaining'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'ok': ok,
    'otp_challenge_id': otpChallengeId,
    'purpose': purpose,
    'channel': channel,
    'expires_at': expiresAt,
    if (resendAvailableAt != null) 'resend_available_at': resendAvailableAt,
    if (attemptsRemaining != null) 'attempts_remaining': attemptsRemaining,
  };
}
