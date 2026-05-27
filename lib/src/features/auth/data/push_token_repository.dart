import 'package:dropx_mobile/src/features/auth/data/dto/push_token_register_response.dart';

abstract class PushTokenRepository {
  /// Register a device FCM token with the backend.
  /// Call after login, after token rotation, and when Firebase issues a new token.
  Future<PushTokenData> registerToken(String token);

  /// Revoke a device FCM token on logout.
  Future<void> revokeToken(String token);
}
