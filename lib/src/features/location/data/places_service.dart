import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlacePrediction {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;

  PlacePrediction({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    final structuredFormatting = json['structured_formatting'] ?? {};
    return PlacePrediction(
      placeId: json['place_id'] ?? '',
      description: json['description'] ?? '',
      mainText: structuredFormatting['main_text'] ?? '',
      secondaryText: structuredFormatting['secondary_text'] ?? '',
    );
  }
}

class PlaceDetails {
  final String placeId;
  final String name;
  final String formattedAddress;
  final LatLng location;

  PlaceDetails({
    required this.placeId,
    required this.name,
    required this.formattedAddress,
    required this.location,
  });

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    final result = json['result'] ?? {};
    final geometry = result['geometry'] ?? {};
    final location = geometry['location'] ?? {};
    return PlaceDetails(
      placeId: result['place_id'] ?? '',
      name: result['name'] ?? '',
      formattedAddress: result['formatted_address'] ?? '',
      location: LatLng(
        (location['lat'] as num?)?.toDouble() ?? 0.0,
        (location['lng'] as num?)?.toDouble() ?? 0.0,
      ),
    );
  }
}

class PlacesService {
  final http.Client _client = http.Client();
  final String _apiKey = 'AIzaSyBW0zgD8_dIPtv9u2UWYM8vWgaIeIMM-Jk';
  final _uuid = const Uuid();
  String? _sessionToken;

  String get sessionToken {
    _sessionToken ??= _uuid.v4();
    return _sessionToken!;
  }

  void clearSessionToken() {
    _sessionToken = null;
  }

  Future<List<PlacePrediction>> getAutocomplete(String input) async {
    if (input.isEmpty) return [];

    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/autocomplete/json',
      {
        'input': input,
        'key': _apiKey,
        'sessiontoken': sessionToken,
        'components': 'country:ng', // Restrict to Nigeria
        'language': 'en',
      },
    );

    try {
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['status'] == 'OK') {
          final predictions = (data['predictions'] as List)
              .map((e) => PlacePrediction.fromJson(e as Map<String, dynamic>))
              .toList();
          return predictions;
        } else {
          debugPrint(
            '[PlacesService] Autocomplete status: ${data['status']} - ${data['error_message'] ?? ''}',
          );
        }
      }
      return [];
    } catch (e) {
      debugPrint('[PlacesService] Error fetching autocomplete: $e');
      return [];
    }
  }

  Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    final uri =
        Uri.https('maps.googleapis.com', '/maps/api/place/details/json', {
          'place_id': placeId,
          'key': _apiKey,
          'sessiontoken': _sessionToken ?? '',
          'fields': 'name,formatted_address,geometry,place_id',
          'language': 'en',
        });

    try {
      final response = await _client.get(uri);

      // End the billing session after details fetch
      clearSessionToken();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['status'] == 'OK') {
          return PlaceDetails.fromJson(data);
        } else {
          debugPrint(
            '[PlacesService] Details status: ${data['status']} - ${data['error_message'] ?? ''}',
          );
        }
      }
      return null;
    } catch (e) {
      debugPrint('[PlacesService] Error fetching place details: $e');
      return null;
    }
  }
}
