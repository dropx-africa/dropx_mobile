import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/common_widgets/app_appbar.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/app_search_bar.dart';
import 'package:dropx_mobile/src/common_widgets/app_image.dart';
import 'package:dropx_mobile/src/common_widgets/app_empty_state.dart';
import 'package:dropx_mobile/src/common_widgets/app_loading_widget.dart';
import 'package:dropx_mobile/src/features/discover/presentation/widgets/vendor_card.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/models/vendor.dart';
import 'package:dropx_mobile/src/models/menu_item.dart';
import 'package:dropx_mobile/src/models/vendor_category.dart';
import 'package:dropx_mobile/src/features/home/providers/home_feed_providers.dart';
import 'package:dropx_mobile/src/features/vendor/providers/vendor_providers.dart';
import 'package:dropx_mobile/src/features/menu/presentation/widgets/menu_item_card.dart';
import 'package:dropx_mobile/src/route/page.dart';
import 'package:dropx_mobile/src/utils/app_navigator.dart';
import 'package:dropx_mobile/src/common_widgets/app_scaffold.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Food',
    'Pharmacy',
    'Parcel',
    'Retail',
  ];

  VendorCategory? get _activeCategory {
    switch (_selectedCategory) {
      case 'Food':
        return VendorCategory.food;
      case 'Pharmacy':
        return VendorCategory.pharmacy;
      case 'Parcel':
        return VendorCategory.parcel;
      case 'Retail':
        return VendorCategory.retail;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppAppBar(title: 'Discover', showBack: false),
      slivers: [
        // Search bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: AppSearchBar(
              hintText: 'Search for anything',
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
        ),
        // Sticky category filter
        SliverPersistentHeader(
          pinned: true,
          delegate: _CategoryHeaderDelegate(
            categories: _categories,
            selected: _selectedCategory,
            onSelect: (cat) => setState(() => _selectedCategory = cat),
          ),
        ),
        // Content
        ..._buildContent(),
      ],
    );
  }

  List<Widget> _buildContent() {
    if (_searchQuery.isEmpty) {
      return [
        ref
            .watch(vendorsProvider(_activeCategory))
            .when(
              loading: () => const SliverFillRemaining(child: AppLoading()),
              error: (_, __) => SliverFillRemaining(
                child: _buildError('Failed to load vendors'),
              ),
              data: (vendors) => _buildResults(vendors: vendors),
            ),
      ];
    }

    return [
      ref
          .watch(
            searchProvider(
              FeedParams(q: _searchQuery, category: _activeCategory?.name),
            ),
          )
          .when(
            loading: () => const SliverFillRemaining(child: AppLoading()),
            error: (_, __) => SliverFillRemaining(
              child: _buildError('Failed to load search results'),
            ),
            data: (data) =>
                _buildResults(vendors: data.vendors, items: data.items),
          ),
    ];
  }

  /// Single unified renderer — section headers only appear when items are present.
  Widget _buildResults({
    required List<Vendor> vendors,
    List<MenuItem> items = const [],
  }) {
    if (vendors.isEmpty && items.isEmpty) {
      return SliverFillRemaining(
        child: _buildEmpty(
          _searchQuery.isEmpty ? Icons.store_outlined : Icons.search_off,
          _searchQuery.isEmpty ? 'No vendors found' : 'No results found',
          _searchQuery.isEmpty
              ? 'No vendors in this category yet'
              : 'Try a different search term',
        ),
      );
    }

    final showSections = items.isNotEmpty;

    return SliverMainAxisGroup(
      slivers: [
        if (vendors.isNotEmpty) ...[
          if (showSections)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: AppText(
                  'Vendors',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildVendorCard(vendors[index]),
                ),
                childCount: vendors.length,
              ),
            ),
          ),
        ],
        if (items.isNotEmpty) ...[
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: AppText(
                'Menu Items',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: MenuItemCard(item: items[index]),
                ),
                childCount: items.length,
              ),
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  Widget _buildVendorCard(Vendor vendor) {
    return VendorCard(
      vendor: vendor,
      onTap: () => AppNavigator.push(
        context,
        AppRoute.vendorMenu,
        arguments: {'vendorId': vendor.id},
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppColors.slate200),
          const SizedBox(height: 12),
          AppText(message, color: AppColors.slate400),
        ],
      ),
    );
  }

  Widget _buildEmpty(IconData icon, String title, String subtitle) {
    return AppEmptyState(icon: icon, title: title, message: subtitle);
  }
}

class _CategoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelect;

  const _CategoryHeaderDelegate({
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  @override
  double get minExtent => 56;
  @override
  double get maxExtent => 56;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selected == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: AppText(
                category,
                color: isSelected ? Colors.white : AppColors.darkBackground,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              selected: isSelected,
              onSelected: (_) => onSelect(category),
              selectedColor: AppColors.primaryOrange,
              backgroundColor: AppColors.slate50,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  bool shouldRebuild(_CategoryHeaderDelegate old) =>
      old.selected != selected || old.categories != categories;
}
