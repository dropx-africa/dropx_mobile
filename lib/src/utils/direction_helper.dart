import 'dart:convert';
import 'package:dropx_mobile/src/core/app_config.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class DirectionsHelper {
  static const _apiKey = AppConfig.googleMapsApiKey;

  /// Returns an ordered list of LatLng points that follow real roads.
  static Future<List<LatLng>> getRoutePoints({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final uri = Uri.https('maps.googleapis.com', '/maps/api/directions/json', {
      'origin': '${origin.latitude},${origin.longitude}',
      'destination': '${destination.latitude},${destination.longitude}',
      'mode': 'driving',
      'key': _apiKey,
    });

    debugPrint('[Directions] Requesting route: $uri');

    final response = await http.get(uri);
    final data = json.decode(response.body) as Map<String, dynamic>;

    debugPrint('[Directions] Status: ${data['status']}');

    if (data['status'] != 'OK') {
      debugPrint('[Directions] Failed: ${data['status']} — ${data['error_message'] ?? ''}');
      return [];
    }

    final encoded =
        data['routes'][0]['overview_polyline']['points'] as String;
    final points = _decodePolyline(encoded);
    debugPrint('[Directions] ✅ Got ${points.length} route points');
    return points;
  }

  static List<LatLng> _decodePolyline(String encoded) {
    final points = <LatLng>[];
    int index = 0;
    final len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int shift = 0, result = 0, b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dLat = (result & 1) != 0 ? ~(result >> 1) : result >> 1;
      lat += dLat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dLng = (result & 1) != 0 ? ~(result >> 1) : result >> 1;
      lng += dLng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }
}
