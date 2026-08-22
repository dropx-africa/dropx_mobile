import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dropx_mobile/src/core/network/api_client.dart';
import 'package:dropx_mobile/src/core/network/api_endpoints.dart';
import 'package:dropx_mobile/src/features/location/data/geocode_result.dart';

/// Service for address search and geocoding.
///
/// Routes through the backend's `/maps/*` proxy rather than calling Google
/// Maps Platform directly — the client never holds a Google Maps API key,
/// and the backend can rate-limit / cache these calls server-side.
class PlacesService {
  final ApiClient _apiClient = ApiClient();

  // ── Forward search (autocomplete) ────────────────────────────────────

  /// Search for addresses via the backend autocomplete proxy. Returns a
  /// list of [GeocodeResult] with coordinates resolved via place-details.
  Future<List<GeocodeResult>> autocomplete(
    String query, {
    LatLng? locationBias,
    int radiusMeters = 50000,
  }) async {
    final trimmed = query.trim();
    if (trimmed.length < 3) return [];

    debugPrint('[PlacesService] autocomplete query: "$trimmed"');

    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.mapsAutocomplete,
        queryParams: {'query': trimmed},
        fromJson: (json) => json as Map<String, dynamic>,
      );

      final predictions = response.data['results'] as List? ?? [];
      debugPrint(
        '[PlacesService] autocomplete → ${predictions.length} predictions',
      );

      final results = <GeocodeResult>[];
      for (final pred in predictions.take(5)) {
        final map = pred as Map<String, dynamic>;
        final placeId = map['place_id'] as String?;
        final description = map['description'] as String? ?? '';
        if (placeId == null) continue;

        final details = await _placeDetails(placeId);
        if (details != null) {
          results.add(
            GeocodeResult(
              placeId: placeId,
              formattedAddress: details.formattedAddress.isNotEmpty
                  ? details.formattedAddress
                  : description,
              lat: details.lat,
              lng: details.lng,
              provider: details.provider,
            ),
          );
        }
      }
      return results;
    } catch (e) {
      debugPrint('[PlacesService] ❌ autocomplete error: $e');
      return [];
    }
  }

  /// Resolve a place_id (from autocomplete) into a full [GeocodeResult].
  Future<GeocodeResult?> _placeDetails(String placeId) async {
    try {
      final response = await _apiClient.get<GeocodeResult>(
        ApiEndpoints.mapsPlaceDetails,
        queryParams: {'place_id': placeId},
        fromJson: (json) {
          final map = json as Map<String, dynamic>;
          final data = map['data'] as Map<String, dynamic>? ?? map;
          return GeocodeResult.fromJson(data);
        },
      );
      return response.data;
    } catch (e) {
      debugPrint('[PlacesService] ❌ placeDetails error: $e');
      return null;
    }
  }

  // ── Address component extraction ─────────────────────────────────────

  /// Reverse geocode a [LatLng] and extract city, state, and formatted address.
  Future<({String city, String state, String formattedAddress})>
  extractAddressComponents(LatLng position) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.mapsReverseGeocode,
        queryParams: {
          'lat': '${position.latitude}',
          'lng': '${position.longitude}',
        },
        fromJson: (json) => json as Map<String, dynamic>,
      );

      final result = response.data['result'] as Map<String, dynamic>?;
      if (result == null) {
        return (city: '', state: '', formattedAddress: '');
      }

      final city = result['city'] as String? ?? '';
      final state = result['state'] as String? ?? '';
      final formatted = result['formatted_address'] as String? ?? '';

      debugPrint(
        '[PlacesService] extractAddressComponents → city=$city, state=$state',
      );
      return (city: city, state: state, formattedAddress: formatted);
    } catch (e) {
      debugPrint('[PlacesService] ❌ extractAddressComponents error: $e');
      return (city: '', state: '', formattedAddress: '');
    }
  }

  // ── Reverse geocode (simple) ─────────────────────────────────────────

  /// Reverse geocode a [LatLng] to a formatted address string.
  Future<String?> reverseGeocode(LatLng position) async {
    debugPrint(
      '[PlacesService] reverseGeocode called for: ${position.latitude}, ${position.longitude}',
    );
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.mapsReverseGeocode,
        queryParams: {
          'lat': '${position.latitude}',
          'lng': '${position.longitude}',
        },
        fromJson: (json) => json as Map<String, dynamic>,
      );

      final result = response.data['result'] as Map<String, dynamic>?;
      final address = result?['formatted_address'] as String?;
      debugPrint('[PlacesService] ✅ Resolved address: $address');
      return address;
    } catch (e) {
      debugPrint('[PlacesService] ❌ Exception during reverse geocoding: $e');
      return null;
    }
  }
}
