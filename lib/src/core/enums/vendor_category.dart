/// Vendor categories used as feed vertical filters.
/// Parcel is not a feed filter — it navigates to the parcel screen.
enum VendorCategory {
  food('food'),
  pharmacy('pharmacy'),
  retail('retail');

  final String apiValue;
  const VendorCategory(this.apiValue);

  String get label {
    switch (this) {
      case VendorCategory.food:
        return 'Food';
      case VendorCategory.pharmacy:
        return 'Pharmacy';
      case VendorCategory.retail:
        return 'Retail';
    }
  }

  static VendorCategory fromString(String value) {
    return VendorCategory.values.firstWhere(
      (e) => e.apiValue == value.toLowerCase(),
      orElse: () => VendorCategory.food,
    );
  }
}
