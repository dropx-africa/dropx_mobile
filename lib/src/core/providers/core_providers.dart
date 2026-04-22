import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/core/network/api_client.dart';
import 'package:dropx_mobile/src/core/services/session_service.dart';
import 'package:dropx_mobile/src/features/location/data/places_service.dart';
import 'package:dropx_mobile/src/features/location/data/location_repository.dart';
import 'package:dropx_mobile/src/features/location/data/remote_location_repository.dart';
import 'package:dropx_mobile/src/features/location/data/address_repository.dart';
import 'package:dropx_mobile/src/features/location/data/remote_address_repository.dart';
import 'package:dropx_mobile/src/route/page.dart';

/// Core-level Riverpod providers shared across the entire app.

/// Global navigator key — used for imperative navigation outside widget tree.
final appNavigatorKey = GlobalKey<NavigatorState>();

/// Provides the session service for persisting user state.
///
/// Must be overridden in `main.dart` with a real instance.
final sessionServiceProvider = Provider<SessionService>((ref) {
  throw UnimplementedError('sessionServiceProvider must be overridden');
});

/// Provides the API client with session tokens and callbacks wired up.
final apiClientProvider = Provider<ApiClient>((ref) {
  final session = ref.watch(sessionServiceProvider);
  final client = ApiClient();

  final token = session.authToken;
  final refresh = session.refreshToken;
  if (token != null && token.isNotEmpty) {
    client.setAuthToken(token, refreshToken: refresh);
  }

  client.onTokenRefreshed = (newToken, newRefresh) {
    session.saveAuthSession(
      accessToken: newToken,
      refreshToken: newRefresh,
      userId: session.userId ?? '',
      fullName: session.fullName,
      phone: session.phone,
    );
  };

  client.onUnauthorized = () async {
    await session.clearSession();
    appNavigatorKey.currentState?.pushNamedAndRemoveUntil(
      AppRoute.login,
      (route) => false,
    );
  };

  return client;
});

/// Provides the PlacesService for Google Places API (reverse geocoding).
final placesServiceProvider = Provider<PlacesService>((ref) {
  return PlacesService();
});

/// Provides the LocationRepository for geocoding (address search).
final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return RemoteLocationRepository(ref.watch(apiClientProvider));
});

/// Provides the AddressRepository for saving / fetching user addresses.
final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  return RemoteAddressRepository(ref.watch(apiClientProvider));
});
