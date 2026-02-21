// AuthResponse uses hand-written fromJson/toJson to handle
// both login (top-level user_id) and register (nested user.user_id) shapes.

/// Response model for login and register endpoints.
///
/// Handles both response shapes:
/// - Login:    `{ "ok": true, "user_id": "...", "access_token": "...", ... }`
/// - Register: `{ "ok": true, "user": { "user_id": "..." }, "access_token": "...", ... }`
class AuthResponse {
  final bool ok;
  final String userId;

  final String accessToken;
  final String refreshToken;

  const AuthResponse({
    required this.ok,
    required this.userId,
    required this.accessToken,
    required this.refreshToken,
  });

  /// Custom fromJson that extracts user_id from either top-level or nested user object.
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Extract user_id: try top-level first, then nested user object
    String userId = json['user_id'] as String? ?? '';
    if (userId.isEmpty && json['user'] is Map<String, dynamic>) {
      final user = json['user'] as Map<String, dynamic>;
      userId = user['user_id'] as String? ?? '';
    }

    return AuthResponse(
      ok: json['ok'] as bool? ?? false,
      userId: userId,
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'ok': ok,
    'user_id': userId,
    'access_token': accessToken,
    'refresh_token': refreshToken,
  };
}
