import 'package:json_annotation/json_annotation.dart';

/// Unified vendor category enum.
///
/// - [@JsonValue] annotations handle JSON serialization on vendor/order models.
/// - [apiValue] maps each category to the correct feed vertical string for
///   GET /home/feed?vertical=... and GET /search?vertical=...
///   Note: retail sends 'shops' — the backend does NOT accept 'retail' on feed endpoints.
/// - [label] is the user-facing display string for the UI.
///
/// Parcel is included for JSON model completeness but is NOT a feed vertical —
/// it navigates to the parcel screen directly.
/// Pharmacy is included for JSON model completeness but is hidden from
/// customer navigation per launch rules.
enum VendorCategory {
  @JsonValue('food')
  food,

  @JsonValue('pharmacy')
  pharmacy,

  @JsonValue('parcel')
  parcel,

  @JsonValue('retail')
  retail,

  @JsonValue('other')
  other;

  /// The vertical string to send to the feed and search API endpoints.
  /// This is NOT always the same as the enum name or JsonValue.
  /// Specifically: retail → 'shops' (backend maps shops → grocery + retail).
  String get apiValue {
    switch (this) {
      case VendorCategory.food:
        return 'food';
      case VendorCategory.pharmacy:
        return 'pharmacy';
      case VendorCategory.retail:
        return 'shops';
      case VendorCategory.parcel:
        return 'parcel';
      case VendorCategory.other:
        return 'other';
    }
  }

  /// User-facing label shown in the UI.
  String get label {
    switch (this) {
      case VendorCategory.food:
        return 'Food';
      case VendorCategory.pharmacy:
        return 'Pharmacy';
      case VendorCategory.retail:
        return 'Grocery & Retail';
      case VendorCategory.parcel:
        return 'Parcel';
      case VendorCategory.other:
        return 'Other';
    }
  }

  /// Resolve from a raw string. Tries apiValue first, then enum name.
  /// Falls back to [VendorCategory.food] if nothing matches.
  static VendorCategory fromString(String value) {
    final lower = value.toLowerCase();
    // Check apiValue matches first (handles 'shops' → retail)
    for (final e in VendorCategory.values) {
      if (e.apiValue == lower) return e;
    }
    // Fall back to enum name match
    for (final e in VendorCategory.values) {
      if (e.name == lower) return e;
    }
    return VendorCategory.food;
  }
}