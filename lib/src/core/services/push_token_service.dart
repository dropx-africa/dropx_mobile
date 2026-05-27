import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dropx_mobile/src/features/auth/data/push_token_repository.dart';
import 'package:dropx_mobile/src/utils/app_log.dart';

/// Manages FCM push-token lifecycle for the customer app.
///
/// - Call [initialize] once after a successful login.
/// - Call [revokeCurrentToken] before clearing the session on logout.
/// - The token-refresh listener is set up inside [initialize] so re-registering
///   after access-token rotation is handled automatically by the caller.
///
/// All failures are swallowed — push-token issues must never break auth flows.
class PushTokenService {
  final PushTokenRepository _repository;
  bool _listenerAttached = false;

  PushTokenService(this._repository);

  /// Requests notification permission, fetches the current FCM token,
  /// registers it with the backend, and wires up the refresh listener.
  /// Returns `true` if permission was granted, `false` if denied.
  Future<bool> initialize() async {
    try {
      AppLog.d('[Push] initialize() called');

      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      AppLog.d('[Push] permission status: ${settings.authorizationStatus}');

      final granted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;

      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        // TODO: remove before release — for local testing only
        AppLog.d('[Push] *** FCM TOKEN (copy for Firebase Console test) ***\n$token');
        try {
          await _repository.registerToken(token);
          AppLog.d('[Push] token registered with backend successfully');
        } catch (e) {
          AppLog.e('[Push] registerToken FAILED: $e', '');
        }
      } else {
        AppLog.e('[Push] getToken() returned null — check google-services.json and Firebase project config', '');
      }

      // Only attach the refresh listener once per app lifecycle.
      if (!_listenerAttached) {
        _listenerAttached = true;
        FirebaseMessaging.instance.onTokenRefresh.listen(
          (newToken) async {
            AppLog.d('[Push] token refreshed — re-registering');
            try {
              await _repository.registerToken(newToken);
            } catch (e) {
              AppLog.e('[Push] re-register on refresh FAILED: $e', '');
            }
          },
        );
      }

      return granted;
    } catch (e, st) {
      AppLog.e('[Push] initialize() FAILED: $e', st.toString());
      return false;
    }
  }

  /// Fetches the current FCM token and revokes it on the backend.
  /// Call this just before [SessionService.clearSession] on logout.
  Future<void> revokeCurrentToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _repository.revokeToken(token);
      }
    } catch (_) {
      // Non-fatal — logout must always proceed regardless.
    }
  }
}
