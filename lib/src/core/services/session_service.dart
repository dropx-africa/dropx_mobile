import 'package:shared_preferences/shared_preferences.dart';
import 'package:dropx_mobile/src/route/page.dart';

/// Manages persistent user session state.
///
/// Stores onboarding, authentication, token, and location confirmation status
/// so the app can resume where the user left off after restart.
class SessionService {
  final SharedPreferences _prefs;

  SessionService(this._prefs);

  // ── Keys ──────────────────────────────────────────────────────────────
  static const _keyOnboardingSeen = 'onboarding_seen';
  static const _keyIsLoggedIn = 'is_logged_in';
  static const _keyIsGuest = 'is_guest';
  static const _keyLocationConfirmed = 'location_confirmed';
  static const _keySavedAddress = 'saved_address';
  static const _keyAuthToken = 'auth_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyUserId = 'user_id';

  // ── Getters ───────────────────────────────────────────────────────────
  bool get hasSeenOnboarding => _prefs.getBool(_keyOnboardingSeen) ?? false;
  bool get isLoggedIn => _prefs.getBool(_keyIsLoggedIn) ?? false;
  bool get isGuest => _prefs.getBool(_keyIsGuest) ?? false;
  bool get hasConfirmedLocation =>
      _prefs.getBool(_keyLocationConfirmed) ?? false;
  String get savedAddress => _prefs.getString(_keySavedAddress) ?? '';
  String? get authToken => _prefs.getString(_keyAuthToken);
  String? get refreshToken => _prefs.getString(_keyRefreshToken);
  String? get userId => _prefs.getString(_keyUserId);

  // ── Mutators ──────────────────────────────────────────────────────────
  Future<void> markOnboardingDone() async {
    await _prefs.setBool(_keyOnboardingSeen, true);
  }

  Future<void> saveLogin() async {
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setBool(_keyIsGuest, false);
  }

  /// Persist tokens and user ID after a successful login or register.
  Future<void> saveAuthSession({
    required String accessToken,
    required String refreshToken,
    required String userId,
  }) async {
    await _prefs.setString(_keyAuthToken, accessToken);
    await _prefs.setString(_keyRefreshToken, refreshToken);
    await _prefs.setString(_keyUserId, userId);
    await saveLogin();
  }

  /// Shortcut kept for backward compatibility.
  Future<void> saveUserToken(String token) async {
    await _prefs.setString(_keyAuthToken, token);
    await saveLogin();
  }

  Future<void> saveGuestMode() async {
    await _prefs.setBool(_keyIsGuest, true);
    await _prefs.setBool(_keyIsLoggedIn, false);
    await _prefs.setBool(_keyOnboardingSeen, true);
  }

  Future<void> confirmLocation({String address = ''}) async {
    await _prefs.setBool(_keyLocationConfirmed, true);
    if (address.isNotEmpty) {
      await _prefs.setString(_keySavedAddress, address);
    }
  }

  Future<void> clearSession() async {
    await _prefs.setBool(_keyIsLoggedIn, false);
    await _prefs.setBool(_keyIsGuest, false);
    await _prefs.setBool(_keyLocationConfirmed, false);
    await _prefs.remove(_keySavedAddress);
    await _prefs.remove(_keyAuthToken);
    await _prefs.remove(_keyRefreshToken);
    await _prefs.remove(_keyUserId);
    // Note: we deliberately keep onboarding_seen = true
  }

  // ── Routing helper ────────────────────────────────────────────────────
  String getInitialRoute() {
    if (!hasSeenOnboarding) return AppRoute.onboarding;
    if (!isLoggedIn && !isGuest) return AppRoute.login;
    if (!hasConfirmedLocation) return AppRoute.manualLocation;
    return AppRoute.manualLocation;
  }
}
