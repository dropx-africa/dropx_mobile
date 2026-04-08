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
  final String? cursor;

  const FeedParams({
    this.vertical,
    this.q,
    this.lat,
    this.lng,
    this.radiusKm,
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
          cursor == other.cursor;

  @override
  int get hashCode =>
      vertical.hashCode ^
      q.hashCode ^
      lat.hashCode ^
      lng.hashCode ^
      radiusKm.hashCode ^
      cursor.hashCode;
}

/// ─── Data Providers ───────────────────────────────────────────

/// Home feed, parameterized by filters.
final homeFeedProvider = FutureProvider.family<HomeFeedData, FeedParams>((
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
        cursor: params.cursor,
      );
});

/// Global search provider.
final searchProvider = FutureProvider.family<SearchData, FeedParams>((
  ref,
  params,
) {
  return ref
      .watch(homeFeedRepositoryProvider)
      .search(q: params.q, vertical: params.vertical);
});
