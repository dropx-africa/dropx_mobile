/// Response model for the OTP verify endpoint.
///
/// Matches the actual API shape:
/// {
///   "ok": true,
///   "user_id": "usr_customer_123",
///   "access_token": "eyJhbGciOi...",
///   "refresh_token": "eyJhbGciOi...",
///   "must_change_password": false
/// }
class OtpVerifyResponse {
  final bool ok;
  final String userId;
  final String accessToken;
  final String refreshToken;
  final bool mustChangePassword;

  const OtpVerifyResponse({
    required this.ok,
    required this.userId,
    required this.accessToken,
    required this.refreshToken,
    this.mustChangePassword = false,
  });

  factory OtpVerifyResponse.fromJson(Map<String, dynamic> json) {
    return OtpVerifyResponse(
      ok: json['ok'] as bool? ?? true,
      userId: json['user_id'] as String,
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      mustChangePassword: json['must_change_password'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'ok': ok,
    'user_id': userId,
    'access_token': accessToken,
    'refresh_token': refreshToken,
    'must_change_password': mustChangePassword,
  };
}
