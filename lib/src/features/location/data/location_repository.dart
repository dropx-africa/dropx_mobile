import 'package:dropx_mobile/src/features/location/data/geocode_result.dart';
import 'package:dropx_mobile/src/features/location/data/zone_resolution.dart';

/// Abstract location repository for geocoding operations.
abstract class LocationRepository {
  /// Search for an address and return geocode results.
  Future<List<GeocodeResult>> geocode(String query);

  /// Resolve a lat/lng to the zone currently covering it.
  Future<ZoneResolution> resolveZone(double lat, double lng);
}
