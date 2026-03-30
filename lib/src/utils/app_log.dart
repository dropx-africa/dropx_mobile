import 'package:flutter/foundation.dart';

/// Lightweight debug logger — all output is silenced in release builds.
///
/// Usage:
/// ```dart
/// AppLog.d('[OTP] Verifying: $pin');
/// AppLog.e('[OTP] ApiException', e.message);
/// ```
abstract final class AppLog {
  /// Debug info message.
  static void d(String message) {
    if (kDebugMode) print(message);
  }

  /// Error message with an optional detail string.
  static void e(String tag, [String? detail]) {
    if (kDebugMode) print(detail != null ? '$tag: $detail' : tag);
  }
}
