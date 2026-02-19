/// Vendor categories available in the DropX platform.
enum VendorCategory {
  food('Food'),
  parcel('Parcel'),
  pharmacy('Pharmacy'),
  retail('Retail');

  final String label;
  const VendorCategory(this.label);

  /// Parse from API string (case-insensitive).
  static VendorCategory fromString(String value) {
    return VendorCategory.values.firstWhere(
      (e) => e.label.toLowerCase() == value.toLowerCase(),
      orElse: () => VendorCategory.food,
    );
  }
}
