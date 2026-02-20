import 'package:intl/intl.dart';

/// Centralised kobo ↔ naira helpers.
///
/// The backend stores monetary values in **kobo** (100 kobo = ₦1).
/// These utilities handle the conversion and formatting for display.
class CurrencyUtils {
  CurrencyUtils._();

  static final _formatter = NumberFormat('#,##0.00');

  /// Convert a kobo value (dynamic – may arrive as `int`, `double`, `String`,
  /// or `null` from JSON) to a naira [double].
  static double koboToNaira(dynamic koboValue) {
    if (koboValue == null) return 0.0;
    if (koboValue is String) {
      return (double.tryParse(koboValue) ?? 0.0) / 100.0;
    }
    if (koboValue is num) {
      return koboValue.toDouble() / 100.0;
    }
    return 0.0;
  }

  /// Format a kobo value directly to a display string like `"₦1,200.00"`.
  static String formatKoboAsNaira(dynamic koboValue) {
    return '₦${_formatter.format(koboToNaira(koboValue))}';
  }

  /// Format a naira [double] to a display string like `"₦1,200.00"`.
  static String formatNaira(double naira) {
    return '₦${_formatter.format(naira)}';
  }
}
