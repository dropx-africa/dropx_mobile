import 'package:flutter/foundation.dart';

/// Response from /auth/password/reset/request
/// Raw JSON is logged in debug mode so we can see the full shape.
class PasswordResetChallengeResponse {
  final String otpChallengeId;
  final String? resendAvailableAt;
  final String? expiresAt;
  final Map<String, dynamic> raw;

  const PasswordResetChallengeResponse({
    required this.otpChallengeId,
    this.resendAvailableAt,
    this.expiresAt,
    required this.raw,
  });

  factory PasswordResetChallengeResponse.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      debugPrint('[PasswordReset] 📦 Raw response shape: $json');
      debugPrint('[PasswordReset] 🔑 Keys: ${json.keys.toList()}');
    }

    final id = (json['otp_challenge_id'] ??
            json['challenge_id'] ??
            json['id'] ??
            '') as String;

    return PasswordResetChallengeResponse(
      otpChallengeId: id,
      resendAvailableAt: (json['resend_available_at'] ??
          json['next_resend_at']) as String?,
      expiresAt: json['expires_at'] as String?,
      raw: json,
    );
  }
}
