import 'package:dropx_mobile/src/core/network/api_client.dart';
import 'package:dropx_mobile/src/core/network/api_endpoints.dart';
import 'package:dropx_mobile/src/features/location/data/geocode_response.dart';
import 'package:dropx_mobile/src/features/location/data/geocode_result.dart';
import 'package:dropx_mobile/src/features/location/data/location_repository.dart';

/// Remote implementation of [LocationRepository] using the backend API.
class RemoteLocationRepository implements LocationRepository {
  final ApiClient _apiClient;

  const RemoteLocationRepository(this._apiClient);

  @override
  Future<List<GeocodeResult>> geocode(String query) async {
    if (query.trim().isEmpty) return [];

    final response = await _apiClient.get<GeocodeResponse>(
      ApiEndpoints.geocode,
      queryParams: {'query': query},
      fromJson: (json) =>
          GeocodeResponse.fromJson(json as Map<String, dynamic>),
    );

    return response.data.results;
  }
}
