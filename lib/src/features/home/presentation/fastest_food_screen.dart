import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/core/providers/core_providers.dart';
import 'package:dropx_mobile/src/common_widgets/app_appbar.dart';
import 'package:dropx_mobile/src/common_widgets/app_search_bar.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/common_widgets/app_loading_widget.dart';
import 'package:dropx_mobile/src/features/home/widgets/feed_vendor_card.dart';
import 'package:dropx_mobile/src/features/home/providers/home_feed_providers.dart';
import 'package:dropx_mobile/src/features/home/data/feed_item.dart';
import 'package:dropx_mobile/src/models/vendor_category.dart';

class FastestFoodScreen extends ConsumerStatefulWidget {
  const FastestFoodScreen({super.key});

  @override
  ConsumerState<FastestFoodScreen> createState() => _FastestFoodScreenState();
}

class _FastestFoodScreenState extends ConsumerState<FastestFoodScreen> {
  final List<FeedItem> _allItems = [];
  String? _nextCursor;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String _searchQuery = '';
  Timer? _searchDebounce;

  List<FeedItem> get _displayItems {
    final source = _searchQuery.isEmpty
        ? _allItems
        : _allItems
            .where((v) => v.displayName
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
            .toList();

    final filtered =
        source.where((v) => v.etaMinutes != null && v.etaMinutes! > 0).toList()
          ..sort((a, b) {
            final etaCompare = a.etaMinutes!.compareTo(b.etaMinutes!);
            if (etaCompare != 0) return etaCompare;
            final aDist = a.distanceKm ?? double.infinity;
            final bDist = b.distanceKm ?? double.infinity;
            return aDist.compareTo(bDist);
          });

    return filtered.isEmpty ? source : filtered;
  }

  /// Title matches home section: "Fastest Food" when most have eta, else "Nearby Food".
  String get _screenTitle {
    if (_allItems.isEmpty) return 'Nearby Food';
    final withEta = _allItems.where((v) => v.etaMinutes != null && v.etaMinutes! > 0).length;
    final mostHaveEta = withEta >= (_allItems.length * 0.5);
    return mostHaveEta ? 'Fastest Food' : 'Nearby Food';
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    final session = ref.read(sessionServiceProvider);
    final feedData = await ref.read(
      homeFeedProvider(
        FeedParams(
          vertical: VendorCategory.food.name,
          lat: session.savedLat,
          lng: session.savedLng,
          maxEtaMinutes: 35,
          q: _searchQuery.isNotEmpty ? _searchQuery : null,
        ),
      ).future,
    );
    if (!mounted) return;
    setState(() {
      _allItems
        ..clear()
        ..addAll(feedData.items);
      _nextCursor = feedData.nextCursor;
      _hasMore = _nextCursor != null;
      _isLoading = false;
    });
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    final session = ref.read(sessionServiceProvider);
    final feedData = await ref.read(
      homeFeedProvider(
        FeedParams(
          vertical: VendorCategory.food.name,
          lat: session.savedLat,
          lng: session.savedLng,
          maxEtaMinutes: 35,
          cursor: _nextCursor,
          q: _searchQuery.isNotEmpty ? _searchQuery : null,
        ),
      ).future,
    );
    if (!mounted) return;
    setState(() {
      _allItems.addAll(feedData.items);
      _nextCursor = feedData.nextCursor;
      _hasMore = _nextCursor != null;
      _isLoadingMore = false;
    });
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), _loadInitialData);
  }

  @override
  Widget build(BuildContext context) {
    final items = _displayItems;

    return Scaffold(
      backgroundColor: Colors.white,
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          if (scrollInfo.metrics.pixels ==
                  scrollInfo.metrics.maxScrollExtent &&
              !_isLoadingMore &&
              _hasMore) {
            _loadMore();
          }
          return false;
        },
        child: CustomScrollView(
          slivers: [
            AppAppBar(title: _screenTitle),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AppSearchBar(
                  hintText: 'Search fastest food...',
                  onChanged: _onSearchChanged,
                ),
              ),
            ),
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: AppLoading()),
              )
            else if (items.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.store_outlined,
                          size: 64, color: AppColors.slate200),
                      const SizedBox(height: 16),
                      const AppText(
                        'No results found',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 8),
                      AppText(
                        _searchQuery.isNotEmpty
                            ? 'Try a different search term'
                            : 'No fast-delivery vendors near you right now',
                        color: AppColors.slate400,
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent: 240,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => FeedVendorCard(item: items[index]),
                    childCount: items.length,
                  ),
                ),
              ),
              if (_isLoadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: AppLoading()),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ],
        ),
      ),
    );
  }
}
