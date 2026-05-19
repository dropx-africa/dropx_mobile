/// Form validation utilities.
///
/// Follows OWASP, RFC 5322, E.164, and common mobile UX conventions.
/// All validators return null on success, an error string on failure.
library;

class Validators {
  Validators._();


  /// RFC 5322-compliant email — handles subdomains, plus addressing, TLDs up to 63 chars.
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&'
    r"'"
    r'*+/=?^_`{|}~-]+'
    r'@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?'
    r'(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*'
    r'\.[a-zA-Z]{2,63}$',
  );

  /// E.164 international format — required by most telecom APIs.
  static final _e164Regex = RegExp(r'^\+[1-9]\d{7,14}$');

  /// OWASP safe name — allows unicode letters, hyphens, apostrophes, spaces.
  static final _nameRegex = RegExp(r"^[\p{L}\p{M}'\-\s]{2,100}$", unicode: true);

  /// Digits only (for OTP, PIN, etc.)
  static final _digitsOnly = RegExp(r'^\d+$');

  /// At least one uppercase letter.
  static final _hasUppercase = RegExp(r'[A-Z]');

  /// At least one lowercase letter.
  static final _hasLowercase = RegExp(r'[a-z]');

  /// At least one digit.
  static final _hasDigit = RegExp(r'\d');

  /// At least one special character (OWASP recommended set).
  static final _hasSpecialChar = RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=\[\]\\;/`~]');


  /// Validates a required field is not empty.
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates minimum character length.
  static String? minLength(
      String? value,
      int min, {
        String fieldName = 'This field',
      }) {
    if (value == null || value.isEmpty) return '$fieldName is required';
    if (value.length < min) return '$fieldName must be at least $min characters';
    return null;
  }

  /// Validates maximum character length.
  static String? maxLength(
      String? value,
      int max, {
        String fieldName = 'This field',
      }) {
    if (value != null && value.length > max) {
      return '$fieldName must be no more than $max characters';
    }
    return null;
  }


  /// Validates a full name.
  ///
  /// - 2–100 characters
  /// - Unicode letters, hyphens, apostrophes, spaces only
  /// - Must contain at least two parts (first + last)
  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Full name is required';

    final trimmed = value.trim();
    if (trimmed.length < 2) return 'Name is too short';
    if (trimmed.length > 100) return 'Name is too long';
    if (!_nameRegex.hasMatch(trimmed)) {
      return 'Name contains invalid characters';
    }
    if (!trimmed.contains(' ')) {
      return 'Please enter your first and last name';
    }
    return null;
  }

  /// Validates a first or last name individually.
  static String? name(String? value, {String fieldName = 'Name'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    final trimmed = value.trim();
    if (trimmed.length < 2) return '$fieldName is too short';
    if (trimmed.length > 50) return '$fieldName is too long';
    if (!_nameRegex.hasMatch(trimmed)) return '$fieldName contains invalid characters';
    return null;
  }

  /// Validates an email address (RFC 5322).
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email address is required';
    final trimmed = value.trim();
    if (trimmed.length > 254) return 'Email address is too long'; // RFC 5321
    if (!_emailRegex.hasMatch(trimmed)) return 'Enter a valid email address';
    return null;
  }

  /// Validates an E.164 phone number (e.g. +2349012345678).
  ///
  /// Use this after the phone picker has already formatted the value.
  static String? phoneE164(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number is required';
    if (!_e164Regex.hasMatch(value.trim())) {
      return 'Enter a valid phone number including country code';
    }
    return null;
  }

  /// Validates a raw local phone number (display only — prefer [phoneE164] for API calls).
  static String? phoneLocal(String? value, {int minDigits = 7, int maxDigits = 15}) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    final digits = value.replaceAll(RegExp(r'[\s\-().+]'), '');
    if (!_digitsOnly.hasMatch(digits)) return 'Phone number contains invalid characters';
    if (digits.length < minDigits) return 'Phone number is too short';
    if (digits.length > maxDigits) return 'Phone number is too long';
    return null;
  }


  /// Validates a password against OWASP and NIST 800-63B recommendations:
  ///
  /// - Minimum 8 characters (NIST: length over complexity)
  /// - At least one uppercase letter
  /// - At least one lowercase letter
  /// - At least one digit
  /// - At least one special character
  /// - Maximum 128 characters (OWASP upper bound)
  ///
  /// Pass [requireSpecialChar: false] to relax for systems that don't support it.
  static String? password(
      String? value, {
        int minLength = 8,
        bool requireUppercase = true,
        bool requireLowercase = true,
        bool requireDigit = true,
        bool requireSpecialChar = true,
      }) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    if (value.length > 128) return 'Password must be no more than 128 characters';
    if (requireUppercase && !_hasUppercase.hasMatch(value)) {
      return 'Password must include at least one uppercase letter';
    }
    if (requireLowercase && !_hasLowercase.hasMatch(value)) {
      return 'Password must include at least one lowercase letter';
    }
    if (requireDigit && !_hasDigit.hasMatch(value)) {
      return 'Password must include at least one number';
    }
    if (requireSpecialChar && !_hasSpecialChar.hasMatch(value)) {
      return 'Password must include at least one special character';
    }
    return null;
  }

  /// Validates a password confirmation matches the original.
  static String? confirmPassword(String? value, String? original) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != original) return 'Passwords do not match';
    return null;
  }

  /// Validates a numeric OTP / PIN of exact length.
  static String? otp(String? value, {int length = 6}) {
    if (value == null || value.trim().isEmpty) return 'Verification code is required';
    final trimmed = value.trim();
    if (!_digitsOnly.hasMatch(trimmed)) return 'Code must contain digits only';
    if (trimmed.length != length) return 'Code must be exactly $length digits';
    return null;
  }


  /// Validates a monetary amount (positive, up to 2 decimal places).
  static String? amount(String? value, {double min = 0.01, double? max}) {
    if (value == null || value.trim().isEmpty) return 'Amount is required';
    final parsed = double.tryParse(value.replaceAll(',', ''));
    if (parsed == null) return 'Enter a valid amount';
    if (parsed < min) return 'Amount must be at least ${min.toStringAsFixed(2)}';
    if (max != null && parsed > max) {
      return 'Amount must not exceed ${max.toStringAsFixed(2)}';
    }
    final parts = value.split('.');
    if (parts.length == 2 && parts[1].length > 2) {
      return 'Amount cannot have more than 2 decimal places';
    }
    return null;
  }

  //Composition helpers

  /// Runs a list of validators in sequence, returning the first error found.
  ///
  /// Example:
  /// ```dart
  /// Validators.compose([
  ///   () => Validators.required(value),
  ///   () => Validators.minLength(value, 3),
  /// ]);
  /// ```
  static String? compose(List<String? Function()> validators) {
    for (final validate in validators) {
      final error = validate();
      if (error != null) return error;
    }
    return null;
  }
}