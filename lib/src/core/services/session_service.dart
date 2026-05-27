import 'package:flutter/foundation.dart';
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
  static const _keyEmail = 'email';
  static const _keyFullName = 'full_name';
  static const _keyPhone = 'phone';
  static const _keyLoginMethod = 'login_method';
  static const _keySavedLat = 'saved_lat';
  static const _keySavedLng = 'saved_lng';
  static const _keySavedCity = 'saved_city';
  static const _keySavedState = 'saved_state';
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
  String? get authToken => _prefs.getString(_keyAuthToken);
  String? get refreshToken => _prefs.getString(_keyRefreshToken);
  String? get userId => _prefs.getString(_keyUserId);
  String get email => _prefs.getString(_keyEmail) ?? '';
  String get fullName => _prefs.getString(_keyFullName) ?? '';
  String get phone => _prefs.getString(_keyPhone) ?? '';
  String get loginMethod => _prefs.getString(_keyLoginMethod) ?? '';
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
      await _prefs.setString(_keyAuthToken, accessToken);
    }
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _prefs.setString(_keyRefreshToken, refreshToken);
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
    debugPrint('[SessionService] saveAuthSession → '
        'fullName="${_prefs.getString(_keyFullName)}" '
        'phone="${_prefs.getString(_keyPhone)}" '
        'email="${_prefs.getString(_keyEmail)}" '
        'loginMethod="${_prefs.getString(_keyLoginMethod)}"');
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
    await _prefs.remove(_keyAuthToken);
    await _prefs.remove(_keyRefreshToken);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keySavedCity);
    await _prefs.remove(_keySavedState);
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
}
