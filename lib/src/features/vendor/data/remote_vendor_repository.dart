import 'package:dropx_mobile/src/core/network/api_client.dart';
import 'package:dropx_mobile/src/models/vendor_category.dart';
import 'package:dropx_mobile/src/core/network/api_endpoints.dart';
import 'package:dropx_mobile/src/features/vendor/data/dto/store_catalog_response.dart';
import 'package:dropx_mobile/src/features/vendor/data/dto/vendors_response.dart';
import 'package:dropx_mobile/src/features/vendor/data/dto/vendor_response.dart';
import 'package:dropx_mobile/src/features/vendor/data/vendor_repository.dart';
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
  }) async {
    final queryParams = <String, String>{};
    if (zoneId != null) queryParams['zone_id'] = zoneId;

    final response = await _apiClient.get<VendorsResponse>(
      ApiEndpoints.vendors,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (json) =>
          VendorsResponse.fromJson(json as Map<String, dynamic>),
    );

    final vendors = response.data.vendors;
    if (kDebugMode) {
      print('[VENDOR] Fetched ${vendors.length} vendors');
    }
    if (category != null) {
      return vendors.where((v) => v.category == category).toList();
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
  Future<StoreCatalogResponse> getStoreCatalog(String vendorId) async {
    final response = await _apiClient.get<StoreCatalogResponse>(
      ApiEndpoints.storeCatalog(vendorId),
      fromJson: (json) =>
          StoreCatalogResponse.fromJson(json as Map<String, dynamic>),
    );

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
  Future<List<Vendor>> searchVendors(String query) async {
    final vendors = await getVendors();
    final lowered = query.toLowerCase();
    return vendors
        .where(
          (v) =>
              v.name.toLowerCase().contains(lowered) ||
              (v.tags?.any((t) => t.toLowerCase().contains(lowered)) ?? false),
        )
        .toList();
  }
}
