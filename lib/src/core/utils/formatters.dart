/// Centralized formatting utilities.
///
/// Extracted from individual screens to eliminate duplication.
/// Every screen that was doing `_formatPrice()` locally should import this.
library;

class Formatters {
  Formatters._();

  /// Format a price to Nigerian Naira with comma separators.
  /// Example: 2500.0 → "₦2,500"
  static String formatNaira(double price) {
    return '₦${formatNumber(price.toInt())}';
  }

  /// Format a number with comma separators.
  /// Example: 2500 → "2,500"
  static String formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  /// Format a date string to a human-readable format.
  /// Example: "2025-02-14T15:00:00Z" → "Feb 14, 2025"
  static String formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (_) {
      return isoDate;
    }
  }

  /// Format a DateTime to time string.
  /// Example: DateTime → "3:00 PM"
  static String formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}
