import 'package:dropx_mobile/src/models/vendor.dart';
import 'package:dropx_mobile/src/models/menu_item.dart';

/// Abstract repository interface for vendor-related data operations.
///
/// Both mock and API implementations satisfy this contract,
/// enabling seamless swapping via Riverpod providers.
abstract class VendorRepository {
  /// Get all vendors, optionally filtered by category.
  Future<List<Vendor>> getVendors({String? category});

  /// Get a single vendor by ID.
  Future<Vendor> getVendorById(String id);

  /// Get menu items for a specific vendor.
  Future<List<MenuItem>> getMenuItems(String vendorId);

  /// Search vendors by name query.
  Future<List<Vendor>> searchVendors(String query);
}
