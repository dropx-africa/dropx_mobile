import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/features/vendor/data/vendor_repository.dart';
import 'package:dropx_mobile/src/features/vendor/data/mock_vendor_repository.dart';
import 'package:dropx_mobile/src/models/vendor.dart';
import 'package:dropx_mobile/src/models/menu_item.dart';

/// ─── Repository Provider ──────────────────────────────────────
///
/// This is the single toggle point for swapping mock ↔ real API.
/// When the API is ready, change [MockVendorRepository] to
/// [VendorRepositoryImpl] and inject [apiClientProvider].
final vendorRepositoryProvider = Provider<VendorRepository>((ref) {
  // TODO: Swap to VendorRepositoryImpl(ref.watch(apiClientProvider))
  return MockVendorRepository();
});

/// ─── Data Providers ───────────────────────────────────────────

/// All vendors, optionally filtered by category.
final vendorsProvider = FutureProvider.family<List<Vendor>, String?>((
  ref,
  category,
) {
  return ref.watch(vendorRepositoryProvider).getVendors(category: category);
});

/// Single vendor by ID.
final vendorByIdProvider = FutureProvider.family<Vendor, String>((ref, id) {
  return ref.watch(vendorRepositoryProvider).getVendorById(id);
});

/// Menu items for a specific vendor.
final menuItemsProvider = FutureProvider.family<List<MenuItem>, String>((
  ref,
  vendorId,
) {
  return ref.watch(vendorRepositoryProvider).getMenuItems(vendorId);
});

/// Search vendors by query.
final vendorSearchProvider = FutureProvider.family<List<Vendor>, String>((
  ref,
  query,
) {
  return ref.watch(vendorRepositoryProvider).searchVendors(query);
});
