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
  final String? category;
  final String? q;
  final int? maxEtaMinutes;
  final double? lat;
  final double? lng;
  final double? radiusKm;

  const FeedParams({
    this.category,
    this.q,
    this.maxEtaMinutes,
    this.lat,
    this.lng,
    this.radiusKm,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeedParams &&
          runtimeType == other.runtimeType &&
          category == other.category &&
          q == other.q &&
          maxEtaMinutes == other.maxEtaMinutes &&
          lat == other.lat &&
          lng == other.lng &&
          radiusKm == other.radiusKm;

  @override
  int get hashCode =>
      category.hashCode ^
      q.hashCode ^
      maxEtaMinutes.hashCode ^
      lat.hashCode ^
      lng.hashCode ^
      radiusKm.hashCode;
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
        category: params.category,
        q: params.q,
        maxEtaMinutes: params.maxEtaMinutes,
        lat: params.lat,
        lng: params.lng,
        radiusKm: params.radiusKm,
      );
});

/// Global search provider.
final searchProvider = FutureProvider.family<SearchData, FeedParams>((
  ref,
  params,
) {
  return ref
      .watch(homeFeedRepositoryProvider)
      .search(q: params.q, category: params.category);
});
