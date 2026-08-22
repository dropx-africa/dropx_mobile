import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:dropx_mobile/src/core/network/api_client.dart';
import 'package:dropx_mobile/src/core/network/api_endpoints.dart';
import 'package:dropx_mobile/src/core/services/session_service.dart';

/// Enforces idle and absolute session timeouts by polling
/// `GET /auth/session-policy` and comparing against activity recorded in
/// [SessionService]. Falls back to 30-minute idle / 7-day absolute
/// defaults if the policy call fails.
class SessionTimeoutCoordinator with WidgetsBindingObserver {
  SessionTimeoutCoordinator({
    required ApiClient apiClient,
    required SessionService session,
    required VoidCallback onTimeout,
  }) : _apiClient = apiClient,
       _session = session,
       _onTimeout = onTimeout;

  final ApiClient _apiClient;
  final SessionService _session;
  final VoidCallback _onTimeout;

  Timer? _ticker;
  int _idleTimeoutSeconds = 1800;
  int _absoluteTimeoutSeconds = 604800;
  bool _started = false;

  Future<void> start() async {
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addObserver(this);

    if (!_session.isLoggedIn) return;
    await _reloadPolicy();
    if (_checkTimeouts()) return;
    await _session.markActivity();
    _ensureTicker();
  }

  Future<void> _reloadPolicy() async {
    if (!_session.isLoggedIn) return;
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.sessionPolicy,
        fromJson: (json) => json as Map<String, dynamic>,
      );
      _idleTimeoutSeconds =
          (response.data['session_idle_timeout_seconds'] as num?)?.toInt() ??
          _idleTimeoutSeconds;
      _absoluteTimeoutSeconds =
          (response.data['session_absolute_timeout_seconds'] as num?)
              ?.toInt() ??
          _absoluteTimeoutSeconds;
    } catch (_) {
      // Keep previous / default thresholds.
    }
  }

  void _ensureTicker() {
    if (!_session.isLoggedIn) {
      _ticker?.cancel();
      _ticker = null;
      return;
    }
    _ticker ??= Timer.periodic(
      const Duration(seconds: 15),
      (_) => _checkTimeouts(),
    );
  }

  /// Call on user interaction to reset the idle clock.
  Future<void> recordActivity() async {
    if (!_session.isLoggedIn) return;
    if (_checkTimeouts()) return;
    await _session.markActivity();
  }

  bool _checkTimeouts() {
    if (!_session.isLoggedIn) return false;

    final now = DateTime.now().toUtc();
    final startedAt = _session.sessionStartedAt ?? now;
    final lastActivityAt = _session.lastActivityAt ?? startedAt;

    final absoluteExceeded =
        now.difference(startedAt).inSeconds >= _absoluteTimeoutSeconds;
    final idleExceeded =
        now.difference(lastActivityAt).inSeconds >= _idleTimeoutSeconds;

    if (absoluteExceeded || idleExceeded) {
      _ticker?.cancel();
      _ticker = null;
      _onTimeout();
      return true;
    }
    return false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    if (!_session.isLoggedIn) return;
    unawaited(_onResume());
  }

  Future<void> _onResume() async {
    if (_checkTimeouts()) return;
    await recordActivity();
    await _reloadPolicy();
    _ensureTicker();
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
  }
}
