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

class FeaturedFoodScreen extends ConsumerStatefulWidget {
  const FeaturedFoodScreen({super.key});

  @override
  ConsumerState<FeaturedFoodScreen> createState() => _FeaturedFoodScreenState();
}

class _FeaturedFoodScreenState extends ConsumerState<FeaturedFoodScreen> {
  final List<FeedItem> _items = [];
  String? _nextCursor;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    final session = ref.read(sessionServiceProvider);
    final feedData = await ref.read(
      homeFeedProvider(
        FeedParams(
          category: VendorCategory.food.name,
          lat: session.savedLat,
          lng: session.savedLng,
          q: _searchQuery.isNotEmpty ? _searchQuery : null,
        ),
      ).future,
    );
    if (!mounted) return;
    setState(() {
      _items
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
          category: VendorCategory.food.name,
          lat: session.savedLat,
          lng: session.savedLng,
          cursor: _nextCursor,
          q: _searchQuery.isNotEmpty ? _searchQuery : null,
        ),
      ).future,
    );
    if (!mounted) return;
    setState(() {
      _items.addAll(feedData.items);
      _nextCursor = feedData.nextCursor;
      _hasMore = _nextCursor != null;
      _isLoadingMore = false;
    });
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
    _loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
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
            const AppAppBar(title: 'Featured Food'),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AppSearchBar(
                  hintText: 'Search featured food...',
                  onChanged: _onSearchChanged,
                ),
              ),
            ),
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: AppLoadingWidget()),
              )
            else if (_items.isEmpty)
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
                            : 'No featured food available right now',
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
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => FeedVendorCard(
                      item: _items[index],
                      width: double.infinity,
                    ),
                    childCount: _items.length,
                  ),
                ),
              ),
              if (_isLoadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: AppLoadingWidget()),
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
