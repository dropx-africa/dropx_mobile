import 'package:dropx_mobile/src/features/location/data/geocode_result.dart';

/// Abstract location repository for geocoding operations.
abstract class LocationRepository {
  /// Search for an address and return geocode results.
  Future<List<GeocodeResult>> geocode(String query);
}
