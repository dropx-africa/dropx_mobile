/// Form validation utilities.
///
/// Provides consistent validation across all forms in the app.
library;

class Validators {
  Validators._();

  /// Validate a phone number (Nigerian format).
  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    // Remove spaces and dashes
    final cleaned = value.replaceAll(RegExp(r'[\s-]'), '');
    if (cleaned.length < 10 || cleaned.length > 15) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  /// Validate a required field.
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate an email address.
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Validate minimum length.
  static String? minLength(
    String? value,
    int minLength, [
    String fieldName = 'This field',
  ]) {
    if (value == null || value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    return null;
  }
}
