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

    try {
      final response = await _client.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['status'] == 'OK') {
          final results = data['results'] as List;
          if (results.isNotEmpty) {
            return (results.first as Map<String, dynamic>)['formatted_address']
                as String?;
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('[PlacesService] Error reverse geocoding: $e');
      return null;
    }
  }
}
