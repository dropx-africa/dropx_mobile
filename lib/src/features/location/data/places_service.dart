import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dropx_mobile/src/features/location/data/geocode_result.dart';

/// Service for Google Maps geocoding and Places Autocomplete.
///
/// Forward search (autocomplete) and reverse geocoding (coords → address)
/// both use the Google Maps Platform APIs directly.
class PlacesService {
  final http.Client _client = http.Client();
  final String _apiKey = 'AIzaSyBW0zgD8_dIPtv9u2UWYM8vWgaIeIMM-Jk';

  // ── Forward search (autocomplete) ────────────────────────────────────

  /// Search for addresses using Google Places Autocomplete.
  /// Returns a list of [GeocodeResult] with coordinates resolved via
  /// the Place Details API.
  Future<List<GeocodeResult>> autocomplete(String query) async {
    if (query.trim().isEmpty) return [];

    // 1. Get autocomplete predictions
    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/autocomplete/json',
      {
        'input': query,
        'key': _apiKey,
        'components': 'country:ng',
        'language': 'en',
      },
    );

    debugPrint('[PlacesService] autocomplete query: "$query"');

    try {
      final response = await _client.get(uri);
      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['status'] != 'OK') {
        debugPrint('[PlacesService] autocomplete status: ${data['status']}');
        return [];
      }

      final predictions = data['predictions'] as List;
      debugPrint(
        '[PlacesService] autocomplete → ${predictions.length} predictions',
      );

      // 2. Resolve each prediction to a GeocodeResult with lat/lng
      final results = <GeocodeResult>[];
      for (final pred in predictions.take(5)) {
        final placeId = pred['place_id'] as String;
        final description = pred['description'] as String;

        // Get coordinates via Place Details
        final coords = await _getPlaceDetails(placeId);
        if (coords != null) {
          results.add(
            GeocodeResult(
              placeId: placeId,
              formattedAddress: description,
              lat: coords.latitude,
              lng: coords.longitude,
              provider: 'google',
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

  /// Get lat/lng from a Google Place ID.
  Future<LatLng?> _getPlaceDetails(String placeId) async {
    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/details/json',
      {'place_id': placeId, 'fields': 'geometry', 'key': _apiKey},
    );

    try {
      final response = await _client.get(uri);
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['status'] != 'OK') return null;

      final loc = data['result']['geometry']['location'];
      return LatLng(
        (loc['lat'] as num).toDouble(),
        (loc['lng'] as num).toDouble(),
      );
    } catch (e) {
      debugPrint('[PlacesService] ❌ placeDetails error: $e');
      return null;
    }
  }

  // ── Address component extraction ─────────────────────────────────────

  /// Reverse geocode a [LatLng] and extract city, state, and formatted address.
  Future<({String city, String state, String formattedAddress})>
  extractAddressComponents(LatLng position) async {
    final uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
      'latlng': '${position.latitude},${position.longitude}',
      'key': _apiKey,
      'language': 'en',
    });

    try {
      final response = await _client.get(uri);
      if (response.statusCode != 200) {
        return (city: '', state: '', formattedAddress: '');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['status'] != 'OK') {
        return (city: '', state: '', formattedAddress: '');
      }

      final results = data['results'] as List;
      if (results.isEmpty) {
        return (city: '', state: '', formattedAddress: '');
      }

      final first = results.first as Map<String, dynamic>;
      final formatted = first['formatted_address'] as String? ?? '';
      final components = first['address_components'] as List? ?? [];

      String city = '';
      String state = '';

      for (final comp in components) {
        final types = (comp['types'] as List).cast<String>();
        if (types.contains('locality')) {
          city = comp['long_name'] as String;
        } else if (city.isEmpty &&
            types.contains('administrative_area_level_2')) {
          city = comp['long_name'] as String;
        }
        if (types.contains('administrative_area_level_1')) {
          state = comp['long_name'] as String;
        }
      }

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
    final uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
      'latlng': '${position.latitude},${position.longitude}',
      'key': _apiKey,
      'language': 'en',
    });

    if (kDebugMode) {
      print(
        '[PlacesService] reverseGeocode called for: ${position.latitude}, ${position.longitude}',
      );
      print('[PlacesService] Request URL: $uri');
    }
    try {
      final response = await _client.get(uri);
      if (kDebugMode) {
        print('[PlacesService] Response status: ${response.statusCode}');
        print(
          '[PlacesService] Response body (first 500 chars): ${response.body.length > 500 ? response.body.substring(0, 500) : response.body}',
        );
      }
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (kDebugMode) {
          print('[PlacesService] Geocode API status: ${data['status']}');
        }
        if (data['status'] == 'OK') {
          final results = data['results'] as List;
          if (results.isNotEmpty) {
            final address =
                (results.first as Map<String, dynamic>)['formatted_address']
                    as String?;
            if (kDebugMode) {
              print('[PlacesService] ✅ Resolved address: $address');
            }
            return address;
          } else {
            if (kDebugMode) {
              print('[PlacesService] ⚠️ No results returned');
            }
          }
        } else {
          if (kDebugMode) {
            print(
              '[PlacesService] ⚠️ API error: ${data['error_message'] ?? 'unknown'}',
            );
          }
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('[PlacesService] ❌ Exception during reverse geocoding: $e');
      }
      return null;
    }
  }
}
