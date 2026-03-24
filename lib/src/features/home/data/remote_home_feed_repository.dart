import 'package:flutter/foundation.dart';
import 'package:dropx_mobile/src/core/network/api_client.dart';
import 'package:dropx_mobile/src/core/network/api_endpoints.dart';
import 'package:dropx_mobile/src/features/home/data/home_feed_repository.dart';
import 'package:dropx_mobile/src/features/home/data/home_feed_response.dart';
import 'package:dropx_mobile/src/features/home/data/search_response.dart';

/// Remote implementation of [HomeFeedRepository] using the DropX API.
class RemoteHomeFeedRepository implements HomeFeedRepository {
  final ApiClient _apiClient;

  RemoteHomeFeedRepository(this._apiClient);

  @override
  Future<HomeFeedData> getFeed({
    String? zoneId,
    double? lat,
    double? lng,
    double? radiusKm,
    int? maxEtaMinutes,
    String? category,
    String? q,
    int? limit,
    String? cursor,
  }) async {
    final queryParams = <String, String>{};
    if (zoneId != null) queryParams['zone_id'] = zoneId;
    if (lat != null) queryParams['lat'] = lat.toString();
    if (lng != null) queryParams['lng'] = lng.toString();
    if (radiusKm != null) queryParams['radius_km'] = radiusKm.toString();
    if (maxEtaMinutes != null) {
      queryParams['max_eta_minutes'] = maxEtaMinutes.toString();
    }
    if (category != null) queryParams['category'] = category;
    if (q != null && q.isNotEmpty) queryParams['q'] = q;
    if (limit != null) queryParams['limit'] = limit.toString();
    if (cursor != null) queryParams['cursor'] = cursor;

    debugPrint(
      '🔵 [FEED-API] GET ${ApiEndpoints.baseUrl}${ApiEndpoints.homeFeed} $queryParams',
    );

    final response = await _apiClient.get<HomeFeedData>(
      ApiEndpoints.homeFeed,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (json) => HomeFeedData.fromJson(json as Map<String, dynamic>),
    );

    debugPrint(
      '✅ [FEED-API] GET /home/feed → ${response.data.items.length} items',
    );
    return response.data;
  }

  @override
  Future<SearchData> search({
    String? q,
    String? category,
    int? limit,
    String? cursor,
  }) async {
    final queryParams = <String, String>{};
    if (q != null && q.isNotEmpty) queryParams['q'] = q;
    if (category != null && category.isNotEmpty) {
      queryParams['category'] = category;
    }
    if (limit != null) queryParams['limit'] = limit.toString();
    if (cursor != null) queryParams['cursor'] = cursor;

    debugPrint(
      '🔵 [SEARCH-API] GET ${ApiEndpoints.baseUrl}${ApiEndpoints.search} $queryParams',
    );

    final response = await _apiClient.get<SearchData>(
      ApiEndpoints.search,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (json) => SearchData.fromJson(json as Map<String, dynamic>),
    );

    debugPrint(
      '✅ [SEARCH-API] GET /search → ${response.data.vendors.length} vendors, '
      '${response.data.items.length} items',
    );
    return response.data;
  }
}
