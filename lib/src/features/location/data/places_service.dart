import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Service for Google Maps reverse geocoding (GPS coords → address).
///
/// Forward geocoding (address search) is handled by [LocationRepository]
/// via the backend's `/maps/geocode` endpoint.
class PlacesService {
  final http.Client _client = http.Client();
  final String _apiKey = 'AIzaSyBW0zgD8_dIPtv9u2UWYM8vWgaIeIMM-Jk';

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
