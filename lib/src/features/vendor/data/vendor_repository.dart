import 'package:dropx_mobile/src/models/vendor.dart';
import 'package:dropx_mobile/src/models/menu_item.dart';
import 'package:dropx_mobile/src/features/vendor/data/dto/store_catalog_response.dart';

import 'package:dropx_mobile/src/models/vendor_category.dart';

/// Abstract repository interface for vendor-related data operations.
///
/// Both mock and API implementations satisfy this contract,
/// enabling seamless swapping via Riverpod providers.
abstract class VendorRepository {
  /// Get all vendors, optionally filtered by category.
  Future<List<Vendor>> getVendors({VendorCategory? category, String? zoneId});

  /// Get a single vendor by ID.
  Future<Vendor> getVendorById(String id);

  /// Get menu items for a specific vendor.
  Future<List<MenuItem>> getMenuItems(String vendorId);

  /// Get the full store catalog (store info + items) for a vendor.
  Future<StoreCatalogResponse> getStoreCatalog(String vendorId);

  /// Search vendors by name query.
  Future<List<Vendor>> searchVendors(String query);
}
