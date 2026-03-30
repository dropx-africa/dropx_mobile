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
  final bool mustChangePassword;

  const AuthResponse({
    required this.ok,
    required this.userId,
    required this.accessToken,
    required this.refreshToken,
    this.mustChangePassword = false,
  });

  /// Custom fromJson that extracts user_id from either top-level or nested user object.
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Login returns user_id at top level; register returns it inside user{}.
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
