import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/core/providers/core_providers.dart';
import 'package:dropx_mobile/src/features/home/data/home_feed_repository.dart';
import 'package:dropx_mobile/src/features/home/data/remote_home_feed_repository.dart';
import 'package:dropx_mobile/src/features/home/data/home_feed_response.dart';
import 'package:dropx_mobile/src/features/home/data/search_response.dart';

/// ─── Repository Provider ──────────────────────────────────────
final homeFeedRepositoryProvider = Provider<HomeFeedRepository>((ref) {
  return RemoteHomeFeedRepository(ref.watch(apiClientProvider));
});

/// ─── Feed Parameters ──────────────────────────────────────────
class FeedParams {
  final String? vertical; // e.g. 'food', 'pharmacy', 'retail'
  final String? q;
  final double? lat;
  final double? lng;
  final double? radiusKm;
  final int? maxEtaMinutes;
  final int? limit;
  final String? cursor;

  const FeedParams({
    this.vertical,
    this.q,
    this.lat,
    this.lng,
    this.radiusKm,
    this.maxEtaMinutes,
    this.limit,
    this.cursor,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeedParams &&
          runtimeType == other.runtimeType &&
          vertical == other.vertical &&
          q == other.q &&
          lat == other.lat &&
          lng == other.lng &&
          radiusKm == other.radiusKm &&
          maxEtaMinutes == other.maxEtaMinutes &&
          limit == other.limit &&
          cursor == other.cursor;

  @override
  int get hashCode =>
      vertical.hashCode ^
      q.hashCode ^
      lat.hashCode ^
      lng.hashCode ^
      radiusKm.hashCode ^
      maxEtaMinutes.hashCode ^
      limit.hashCode ^
      cursor.hashCode;
}

/// ─── Data Providers ───────────────────────────────────────────

/// Home feed, parameterized by filters.
///
/// autoDispose so that a distinct provider instance isn't kept alive
/// forever for every search query a customer ever typed — without it,
/// each keystroke's FeedParams permanently caches its own response.
final homeFeedProvider =
    FutureProvider.autoDispose.family<HomeFeedData, FeedParams>((
  ref,
  params,
) {
  return ref
      .watch(homeFeedRepositoryProvider)
      .getFeed(
        vertical: params.vertical,
        q: params.q,
        lat: params.lat,
        lng: params.lng,
        radiusKm: params.radiusKm,
        maxEtaMinutes: params.maxEtaMinutes,
        limit: params.limit,
        cursor: params.cursor,
      );
});

/// Global search provider. autoDispose for the same reason as
/// [homeFeedProvider] — one instance per keystroke would otherwise never
/// be released.
final searchProvider =
    FutureProvider.autoDispose.family<SearchData, FeedParams>((
  ref,
  params,
) {
  return ref
      .watch(homeFeedRepositoryProvider)
      .search(q: params.q, vertical: params.vertical);
});
