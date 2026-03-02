import 'package:dropx_mobile/src/features/home/data/home_feed_response.dart';
import 'package:dropx_mobile/src/features/home/data/search_response.dart';

/// Abstract repository interface for home feed & search operations.
abstract class HomeFeedRepository {
  /// Fetch the home feed with optional filters.
  Future<HomeFeedData> getFeed({
    String? zoneId,
    double? lat,
    double? lng,
    int? maxEtaMinutes,
    String? category,
    String? q,
    int? limit,
    String? cursor,
  });

  /// Search for vendors and items.
  Future<SearchData> search({
    String? q,
    String? category,
    int? limit,
    String? cursor,
  });
}
