import 'package:dropx_mobile/src/core/network/api_client.dart';
import 'package:dropx_mobile/src/models/vendor_category.dart';
import 'package:dropx_mobile/src/core/network/api_endpoints.dart';
import 'package:dropx_mobile/src/features/vendor/data/dto/store_catalog_response.dart';
import 'package:dropx_mobile/src/features/vendor/data/dto/vendors_response.dart';
import 'package:dropx_mobile/src/features/vendor/data/dto/vendor_response.dart';
import 'package:dropx_mobile/src/features/vendor/data/vendor_repository.dart';
import 'package:dropx_mobile/src/features/home/data/search_response.dart';
import 'package:dropx_mobile/src/models/menu_item.dart';
import 'package:dropx_mobile/src/models/vendor.dart';
import 'package:flutter/foundation.dart';

class RemoteVendorRepository implements VendorRepository {
  final ApiClient _apiClient;

  RemoteVendorRepository(this._apiClient);

  @override
  Future<List<Vendor>> getVendors({
    VendorCategory? category,
    String? zoneId,
    double? lat,
    double? lng,
  }) async {
    final queryParams = <String, String>{};
    if (zoneId != null) queryParams['zone_id'] = zoneId;
    if (lat != null) queryParams['lat'] = lat.toString();
    if (lng != null) queryParams['lng'] = lng.toString();

    // Use apiValue so retail sends 'shops', not 'retail'.
    // food sends 'food', pharmacy sends 'pharmacy', etc.
    if (category != null) queryParams['category'] = category.apiValue;

    final response = await _apiClient.get<VendorsResponse>(
      ApiEndpoints.vendors,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (json) =>
          VendorsResponse.fromJson(json as Map<String, dynamic>),
    );

    final vendors = response.data.vendors;
    if (kDebugMode) {
      print(
        '[VENDOR] Fetched ${vendors.length} vendors '
        '(category: ${category?.apiValue ?? 'all'})',
      );
    }
    return vendors;
  }

  @override
  Future<List<MenuItem>> getMenuItems(String vendorId) async {
    final response = await _apiClient.get<StoreCatalogResponse>(
      ApiEndpoints.storeCatalog(vendorId),
      fromJson: (json) =>
          StoreCatalogResponse.fromJson(json as Map<String, dynamic>),
    );

    return response.data.items;
  }

  @override
  Future<StoreCatalogResponse> getStoreCatalog(
    String vendorId, {
    VendorCategory? category,
  }) async {
    final queryParams = <String, String>{};

    // For retail stores, pass ?category=shops so the backend returns
    // the retail catalog. For food, no param is needed.
    if (category != null) queryParams['category'] = category.apiValue;

    final response = await _apiClient.get<StoreCatalogResponse>(
      ApiEndpoints.storeCatalog(vendorId),
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (json) =>
          StoreCatalogResponse.fromJson(json as Map<String, dynamic>),
    );

    if (kDebugMode) {
      print(
        '[VENDOR] Fetched catalog for $vendorId '
        '(category: ${category?.apiValue ?? 'none'})',
      );
    }

    return response.data;
  }

  @override
  Future<Vendor> getVendorById(String id) async {
    final response = await _apiClient.get<VendorResponse>(
      ApiEndpoints.vendorById(id),
      fromJson: (json) => VendorResponse.fromJson(json as Map<String, dynamic>),
    );

    return response.data.vendor;
  }

  @override
  Future<MenuItem> getStoreItem(String vendorId, String itemId) async {
    final response = await _apiClient.get<MenuItem>(
      ApiEndpoints.storeItem(vendorId, itemId),
      fromJson: (json) => MenuItem.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  @override
  Future<List<Vendor>> searchVendors(String query) async {
    if (query.trim().isEmpty) return [];

    final response = await _apiClient.get<SearchData>(
      ApiEndpoints.search,
      queryParams: {'q': query.trim()},
      fromJson: (json) => SearchData.fromJson(json as Map<String, dynamic>),
    );
    return response.data.vendors;
  }
}
