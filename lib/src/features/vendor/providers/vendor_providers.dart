import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/features/vendor/data/vendor_repository.dart';
import 'package:dropx_mobile/src/features/vendor/data/remote_vendor_repository.dart';
import 'package:dropx_mobile/src/features/vendor/data/dto/store_catalog_response.dart';
import 'package:dropx_mobile/src/core/providers/core_providers.dart';
import 'package:dropx_mobile/src/models/vendor.dart';
import 'package:dropx_mobile/src/models/menu_item.dart';
import 'package:dropx_mobile/src/models/vendor_category.dart';

/// ─── Repository Provider ──────────────────────────────────────
final vendorRepositoryProvider = Provider<VendorRepository>((ref) {
  return RemoteVendorRepository(ref.watch(apiClientProvider));
});

/// ─── Store Catalog Params ─────────────────────────────────────
/// Wraps vendorId + optional category so [storeCatalogProvider] can pass
/// ?category=shops for retail stores without breaking existing food calls.
class StoreCatalogParams {
  final String vendorId;

  /// The vertical/category to filter the catalog by.
  /// Pass [VendorCategory.retail] for retail stores → sends 'shops' to API.
  /// Leave null for food vendors → no category param sent.
  final VendorCategory? category;

  const StoreCatalogParams({
    required this.vendorId,
    this.category,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is StoreCatalogParams &&
              runtimeType == other.runtimeType &&
              vendorId == other.vendorId &&
              category == other.category;

  @override
  int get hashCode => vendorId.hashCode ^ category.hashCode;
}

/// ─── Data Providers ───────────────────────────────────────────

/// All vendors, optionally filtered by category.
final vendorsProvider = FutureProvider.family<List<Vendor>, VendorCategory?>((
    ref,
    category,
    ) {
  return ref.watch(vendorRepositoryProvider).getVendors(category: category);
});

/// Vendors filtered by zone ID — used in the cart to fetch vendor info.
final vendorsByZoneProvider = FutureProvider.family<List<Vendor>, String>((
    ref,
    zoneId,
    ) {
  return ref.watch(vendorRepositoryProvider).getVendors(zoneId: zoneId);
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
///
/// Usage — food store (no category param):
/// ```dart
/// ref.watch(storeCatalogProvider(StoreCatalogParams(vendorId: id)))
/// ```
///
/// Usage — retail store (sends ?category=shops):
/// ```dart
/// ref.watch(storeCatalogProvider(StoreCatalogParams(
///   vendorId: id,
///   category: VendorCategory.retail,
/// )))
/// ```
final storeCatalogProvider =
FutureProvider.family<StoreCatalogResponse, StoreCatalogParams>((
    ref,
    params,
    ) {
  return ref
      .watch(vendorRepositoryProvider)
      .getStoreCatalog(params.vendorId, category: params.category);
});

/// Search vendors by query.
final vendorSearchProvider = FutureProvider.family<List<Vendor>, String>((
    ref,
    query,
    ) {
  return ref.watch(vendorRepositoryProvider).searchVendors(query);
});