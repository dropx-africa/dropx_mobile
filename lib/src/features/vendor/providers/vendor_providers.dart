import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/features/vendor/data/vendor_repository.dart';
import 'package:dropx_mobile/src/features/vendor/data/remote_vendor_repository.dart';
import 'package:dropx_mobile/src/features/vendor/data/dto/store_catalog_response.dart';
import 'package:dropx_mobile/src/core/providers/core_providers.dart';
import 'package:dropx_mobile/src/models/vendor.dart';
import 'package:dropx_mobile/src/models/menu_item.dart';
import 'package:dropx_mobile/src/models/vendor_category.dart';

/// ─── Repository Provider ──────────────────────────────────────
///
/// This is the single toggle point for swapping mock ↔ real API.
/// When the API is ready, change [MockVendorRepository] to
/// [VendorRepositoryImpl] and inject [apiClientProvider].
final vendorRepositoryProvider = Provider<VendorRepository>((ref) {
  return RemoteVendorRepository(ref.watch(apiClientProvider));
});

/// ─── Data Providers ───────────────────────────────────────────

/// All vendors, optionally filtered by category.
final vendorsProvider = FutureProvider.family<List<Vendor>, VendorCategory?>((
  ref,
  category,
) {
  return ref.watch(vendorRepositoryProvider).getVendors();
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

/// Full store catalog (store info + items) for a specific vendor.
final storeCatalogProvider =
    FutureProvider.family<StoreCatalogResponse, String>((ref, vendorId) {
      return ref.watch(vendorRepositoryProvider).getStoreCatalog(vendorId);
    });

/// Search vendors by query.
final vendorSearchProvider = FutureProvider.family<List<Vendor>, String>((
  ref,
  query,
) {
  return ref.watch(vendorRepositoryProvider).searchVendors(query);
});
