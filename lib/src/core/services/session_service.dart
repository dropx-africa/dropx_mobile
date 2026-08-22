import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dropx_mobile/src/route/page.dart';

/// Manages persistent user session state.
///
/// Stores onboarding, authentication, token, and location confirmation status
/// so the app can resume where the user left off after restart.
class SessionService {
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;

  // Access/refresh tokens live in Keychain/Keystore-backed secure storage,
  // not SharedPreferences — kept in-memory here too since secure storage
  // reads are async but callers expect a synchronous getter.
  String? _authToken;
  String? _refreshToken;

  static const _secureAuthTokenKey = 'auth_token';
  static const _secureRefreshTokenKey = 'refresh_token';

  SessionService(
    this._prefs, {
    String? authToken,
    String? refreshToken,
    FlutterSecureStorage? secureStorage,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
       _authToken = authToken,
       _refreshToken = refreshToken;

  /// Builds a [SessionService] with tokens loaded from secure storage.
  ///
  /// One-time migration: if secure storage has no tokens yet but the old
  /// plaintext SharedPreferences keys do (from before this migration),
  /// the tokens are moved into secure storage and the plaintext copies are
  /// removed, so an already-logged-in user isn't forced to log in again.
  static Future<SessionService> create(
    SharedPreferences prefs, {
    FlutterSecureStorage? secureStorage,
  }) async {
    final storage = secureStorage ?? const FlutterSecureStorage();
    var authToken = await storage.read(key: _secureAuthTokenKey);
    var refreshToken = await storage.read(key: _secureRefreshTokenKey);

    if (authToken == null && refreshToken == null) {
      final legacyAuthToken = prefs.getString(_keyAuthToken);
      final legacyRefreshToken = prefs.getString(_keyRefreshToken);
      if (legacyAuthToken != null || legacyRefreshToken != null) {
        if (legacyAuthToken != null) {
          await storage.write(
            key: _secureAuthTokenKey,
            value: legacyAuthToken,
          );
        }
        if (legacyRefreshToken != null) {
          await storage.write(
            key: _secureRefreshTokenKey,
            value: legacyRefreshToken,
          );
        }
        await prefs.remove(_keyAuthToken);
        await prefs.remove(_keyRefreshToken);
        authToken = legacyAuthToken;
        refreshToken = legacyRefreshToken;
      }
    }

    return SessionService(
      prefs,
      authToken: authToken,
      refreshToken: refreshToken,
      secureStorage: storage,
    );
  }

  // ── Keys ──────────────────────────────────────────────────────────────
  static const _keyOnboardingSeen = 'onboarding_seen';
  static const _keyIsLoggedIn = 'is_logged_in';
  static const _keyIsGuest = 'is_guest';
  static const _keyLocationConfirmed = 'location_confirmed';
  static const _keySavedAddress = 'saved_address';
  static const _keyAuthToken = 'auth_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyUserId = 'user_id';
  static const _keyEmail = 'email';
  static const _keyFullName = 'full_name';
  static const _keyPhone = 'phone';
  static const _keyLoginMethod = 'login_method';
  static const _keySavedLat = 'saved_lat';
  static const _keySavedLng = 'saved_lng';
  static const _keySavedCity = 'saved_city';
  static const _keySavedState = 'saved_state';
  static const _keySessionStartedAt = 'session_started_at';
  static const _keyLastActivityAt = 'session_last_activity_at';
  static const _keyLastRouteName = 'last_route_name';
  static const _keyLastRouteArgs = 'last_route_args';
  // ── Getters ───────────────────────────────────────────────────────────
  bool get hasSeenOnboarding => _prefs.getBool(_keyOnboardingSeen) ?? false;
  bool get isLoggedIn => _prefs.getBool(_keyIsLoggedIn) ?? false;
  bool get isGuest => _prefs.getBool(_keyIsGuest) ?? false;
  bool get hasConfirmedLocation =>
      _prefs.getBool(_keyLocationConfirmed) ?? false;
  String get savedAddress => _prefs.getString(_keySavedAddress) ?? '';
  double get savedLat => _prefs.getDouble(_keySavedLat) ?? 6.5244;
  double get savedLng => _prefs.getDouble(_keySavedLng) ?? 3.3792;
  String get savedCity => _prefs.getString(_keySavedCity) ?? '';
  String get savedState => _prefs.getString(_keySavedState) ?? '';
  String? get authToken => _authToken;
  String? get refreshToken => _refreshToken;
  String? get userId => _prefs.getString(_keyUserId);
  String get email => _prefs.getString(_keyEmail) ?? '';
  String get fullName => _prefs.getString(_keyFullName) ?? '';
  String get phone => _prefs.getString(_keyPhone) ?? '';
  String get loginMethod => _prefs.getString(_keyLoginMethod) ?? '';
  DateTime? get sessionStartedAt {
    final ms = _prefs.getInt(_keySessionStartedAt);
    return ms != null ? DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true) : null;
  }

  DateTime? get lastActivityAt {
    final ms = _prefs.getInt(_keyLastActivityAt);
    return ms != null ? DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true) : null;
  }

  /// Records user activity for idle-timeout purposes. Also sets the
  /// session start time on first call after login.
  Future<void> markActivity() async {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await _prefs.setInt(_keyLastActivityAt, now);
    if (_prefs.getInt(_keySessionStartedAt) == null) {
      await _prefs.setInt(_keySessionStartedAt, now);
    }
  }
// ── Group Order Session ───────────────────────────────────────────────
  static const _keyGroupOrderId = 'active_group_order_id';
  static const _keyGroupParticipantToken = 'active_group_participant_token';
  static const _keyGroupInviteUrl = 'active_group_invite_url';
  static const _keyGroupVendorId = 'active_group_vendor_id';
  static const _keyGroupIsHost = 'active_group_is_host';

  String? get activeGroupOrderId => _prefs.getString(_keyGroupOrderId);
  String? get activeGroupParticipantToken => _prefs.getString(_keyGroupParticipantToken);
  String? get activeGroupInviteUrl => _prefs.getString(_keyGroupInviteUrl);
  String? get activeGroupVendorId => _prefs.getString(_keyGroupVendorId);
  bool get activeGroupIsHost => _prefs.getBool(_keyGroupIsHost) ?? false;

  Future<void> saveGroupOrderSession({
    required String groupOrderId,
    required String participantToken,
    required bool isHost,
    String? inviteUrl,
    String? vendorId,
  }) async {
    await _prefs.setString(_keyGroupOrderId, groupOrderId);
    await _prefs.setString(_keyGroupParticipantToken, participantToken);
    await _prefs.setBool(_keyGroupIsHost, isHost);
    if (inviteUrl != null) await _prefs.setString(_keyGroupInviteUrl, inviteUrl);
    if (vendorId != null) await _prefs.setString(_keyGroupVendorId, vendorId);
  }

  Future<void> clearGroupOrderSession() async {
    await _prefs.remove(_keyGroupOrderId);
    await _prefs.remove(_keyGroupParticipantToken);
    await _prefs.remove(_keyGroupInviteUrl);
    await _prefs.remove(_keyGroupVendorId);
    await _prefs.remove(_keyGroupIsHost);
  }
  // ── Mutators ──────────────────────────────────────────────────────────
  Future<void> markOnboardingDone() async {
    await _prefs.setBool(_keyOnboardingSeen, true);
  }

  Future<void> saveLogin() async {
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setBool(_keyIsGuest, false);
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await _prefs.setInt(_keySessionStartedAt, now);
    await _prefs.setInt(_keyLastActivityAt, now);
  }

  /// Persist tokens and user ID after a successful login or register.
  Future<void> saveAuthSession({
    String? accessToken,
    String? refreshToken,
    String? userId,
    String? email,
    String? fullName,
    String? phone,
    String? loginMethod,
  }) async {
    if (accessToken != null && accessToken.isNotEmpty) {
      await _secureStorage.write(key: _secureAuthTokenKey, value: accessToken);
      _authToken = accessToken;
    }
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _secureStorage.write(
        key: _secureRefreshTokenKey,
        value: refreshToken,
      );
      _refreshToken = refreshToken;
    }
    if (userId != null && userId.isNotEmpty) {
      await _prefs.setString(_keyUserId, userId);
    }
    if (email != null && email.isNotEmpty) {
      await _prefs.setString(_keyEmail, email);
    }
    if (fullName != null && fullName.isNotEmpty) {
      await _prefs.setString(_keyFullName, fullName);
    }
    if (phone != null && phone.isNotEmpty) {
      await _prefs.setString(_keyPhone, phone);
    }
    if (loginMethod != null && loginMethod.isNotEmpty) {
      await _prefs.setString(_keyLoginMethod, loginMethod);
    }
    if (kDebugMode) {
      debugPrint(
        '[SessionService] saveAuthSession → loginMethod="${_prefs.getString(_keyLoginMethod)}"',
      );
    }
    await saveLogin();
  }

  // /// Shortcut kept for backward compatibility.
  // Future<void> saveUserToken(String token) async {
  //   await _prefs.setString(_keyAuthToken, token);
  //   await saveLogin();
  // }

  Future<void> saveGuestMode() async {
    await _prefs.setBool(_keyIsGuest, true);
    await _prefs.setBool(_keyIsLoggedIn, false);
    await _prefs.setBool(_keyOnboardingSeen, true);
  }

  Future<void> confirmLocation({
    String address = '',
    double? lat,
    double? lng,
    String city = '',
    String state = '',
  }) async {
    await _prefs.setBool(_keyLocationConfirmed, true);
    if (address.isNotEmpty) {
      await _prefs.setString(_keySavedAddress, address);
    }
    if (lat != null) await _prefs.setDouble(_keySavedLat, lat);
    if (lng != null) await _prefs.setDouble(_keySavedLng, lng);
    if (city.isNotEmpty) await _prefs.setString(_keySavedCity, city);
    if (state.isNotEmpty) await _prefs.setString(_keySavedState, state);
  }

  Future<void> clearSession() async {
    await _prefs.setBool(_keyIsLoggedIn, false);
    await _prefs.setBool(_keyIsGuest, false);
    await _prefs.setBool(_keyLocationConfirmed, false);
    await _secureStorage.delete(key: _secureAuthTokenKey);
    await _secureStorage.delete(key: _secureRefreshTokenKey);
    _authToken = null;
    _refreshToken = null;
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keySavedCity);
    await _prefs.remove(_keySavedState);
    await _prefs.remove(_keySessionStartedAt);
    await _prefs.remove(_keyLastActivityAt);
    await _prefs.remove(_keyLastRouteName);
    await _prefs.remove(_keyLastRouteArgs);
    // await _prefs.remove(_keyFullName);
    // await _prefs.remove(_keyPhone);
    // Note: we deliberately keep onboarding_seen = true
  }

  // ── Routing helper ────────────────────────────────────────────────────
  String getInitialRoute() {
    if (!hasSeenOnboarding) return AppRoute.onboarding;
    if (!isLoggedIn) return AppRoute.login;
    if (!hasConfirmedLocation) return AppRoute.manualLocation;
    return AppRoute.dashboard;
  }

  // ── Last active screen ─────────────────────────────────────────────────
  // Lets a cold app restart resume whatever screen the customer was last
  // viewing (order/parcel tracking, cart, wallet, support, etc.) instead
  // of always dropping back to the dashboard. Only a curated allowlist of
  // routes is ever saved here — see RouteResumeObserver.
  String? get lastRouteName => _prefs.getString(_keyLastRouteName);
  String? get lastRouteArgsJson => _prefs.getString(_keyLastRouteArgs);

  Future<void> saveLastRoute({
    required String name,
    required String argsJson,
  }) async {
    await _prefs.setString(_keyLastRouteName, name);
    await _prefs.setString(_keyLastRouteArgs, argsJson);
  }

  Future<void> clearLastRoute() async {
    await _prefs.remove(_keyLastRouteName);
    await _prefs.remove(_keyLastRouteArgs);
  }
}
