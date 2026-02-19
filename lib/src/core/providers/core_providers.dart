import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/core/network/api_client.dart';

import 'package:dropx_mobile/src/core/services/session_service.dart';
import 'package:dropx_mobile/src/features/location/data/places_service.dart';

/// Core-level Riverpod providers shared across the entire app.
///
/// These provide infrastructure services (API client, storage, etc.)
/// that feature-level providers depend on.

/// Provides the API client configured with the base URL.
///
/// When auth is implemented, this will also inject the auth token.
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

/// Provides the session service for persisting user state.
///
/// Must be overridden in `main.dart` with a real instance.
final sessionServiceProvider = Provider<SessionService>((ref) {
  throw UnimplementedError('sessionServiceProvider must be overridden');
});

/// Provides the PlacesService for Google Places API.
final placesServiceProvider = Provider<PlacesService>((ref) {
  return PlacesService();
});
