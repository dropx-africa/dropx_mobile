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
import 'package:dropx_mobile/src/features/cart/providers/cart_provider.dart';
import 'package:dropx_mobile/src/core/providers/core_providers.dart';
import 'package:dropx_mobile/src/features/auth/presentation/sign_up_to_order_sheet.dart';
import 'package:dropx_mobile/src/features/menu/presentation/widgets/menu_item_card.dart';
import 'package:dropx_mobile/src/route/page.dart';
import 'package:dropx_mobile/src/utils/app_navigator.dart';
import 'package:dropx_mobile/src/common_widgets/app_scaffold.dart';
import 'package:dropx_mobile/src/features/menu/presentation/widgets/bottom_cart_bar.dart';
import 'package:dropx_mobile/src/features/menu/presentation/widgets/item_add_sheet.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';

  // When non-null, menu items section shows all items from this vendor
  String? _expandedVendorId;
  String? _expandedVendorName;

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
        return null; // Parcel navigates to ParcelScreen, not a feed filter
      case 'Retail':
        return VendorCategory.retail;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final isGuest = ref.watch(sessionServiceProvider).isGuest;

    // If cart is cleared externally, collapse the vendor items section
    if (cartState.totalItemCount == 0 && _expandedVendorId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _expandedVendorId = null);
      });
    }

    return Stack(
      children: [
        AppScaffold(
          appBar: const AppAppBar(title: 'Discover', showBack: false),
          onRefresh: () async {
            ref.invalidate(homeFeedProvider);
            ref.invalidate(menuItemsProvider);
          },
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: AppSearchBar(
                  hintText: 'Search for anything',
                  onChanged: (value) => setState(() {
                    _searchQuery = value;
                    _expandedVendorId = null;
                    _expandedVendorName = null;
                  }),
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _CategoryHeaderDelegate(
                categories: _categories,
                selected: _selectedCategory,
                onSelect: (cat) => setState(() => _selectedCategory = cat),
              ),
            ),
            ..._buildContent(cartState, isGuest),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
        if (cartState.totalItemCount > 0)
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: BottomCartBar(
              itemCount: cartState.totalItemCount,
              totalPrice: cartState.totalPrice,
              isGuest: isGuest,
            ),
          ),
      ],
    );
  }

  List<Widget> _buildContent(CartState cartState, bool isGuest) {
    if (_searchQuery.isEmpty) {
      return [
        ref
            .watch(vendorsProvider(_activeCategory))
            .when(
              loading: () => const SliverFillRemaining(child: AppLoading()),
              error: (_, __) => SliverFillRemaining(
                child: _buildError('Failed to load vendors'),
              ),
              data: (vendors) =>
                  _buildResults(vendors: vendors, cartState: cartState, isGuest: isGuest),
            ),
      ];
    }

    return [
      ref
          .watch(
            searchProvider(
              FeedParams(q: _searchQuery, vertical: _activeCategory?.name),
            ),
          )
          .when(
            loading: () => const SliverFillRemaining(child: AppLoading()),
            error: (_, __) => SliverFillRemaining(
              child: _buildError('Failed to load search results'),
            ),
            data: (data) => _buildResults(
              vendors: data.vendors,
              items: data.items,
              cartState: cartState,
              isGuest: isGuest,
            ),
          ),
    ];
  }

  Widget _buildResults({
    required List<Vendor> vendors,
    List<MenuItem> items = const [],
    required CartState cartState,
    required bool isGuest,
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
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.70,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildVendorCard(vendors[index]),
                childCount: vendors.length,
              ),
            ),
          ),
        ],
        if (items.isNotEmpty) ...[
          // Header — changes when a vendor is expanded
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: AppText(
                      _expandedVendorId != null
                          ? 'More from ${_expandedVendorName ?? 'this vendor'}'
                          : 'Menu Items',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_expandedVendorId != null)
                    TextButton(
                      onPressed: () => setState(() {
                        _expandedVendorId = null;
                        _expandedVendorName = null;
                      }),
                      child: const AppText(
                        'Show all results',
                        color: AppColors.primaryOrange,
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // If vendor expanded → fetch & show all that vendor's items
          if (_expandedVendorId != null)
            _buildExpandedVendorItems(_expandedVendorId!, cartState, isGuest)
          else
            // Search result items with Add buttons
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildSearchItemCard(
                      items[index],
                      cartState,
                      isGuest,
                    ),
                  ),
                  childCount: items.length,
                ),
              ),
            ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  /// Fetches and renders all menu items for the expanded vendor.
  Widget _buildExpandedVendorItems(
    String vendorId,
    CartState cartState,
    bool isGuest,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      sliver: ref.watch(menuItemsProvider(vendorId)).when(
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: AppLoading()),
              ),
            ),
            error: (_, __) => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: AppText('Could not load vendor items')),
              ),
            ),
            data: (vendorItems) => SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = vendorItems[index];
                  final quantity = cartState.items[item.id]?.quantity ?? 0;
                  return MenuItemCard(
                    item: item,
                    quantity: quantity,
                    onAdd: () => _handleAdd(item, isGuest, cartState),
                    onIncrement: () =>
                        ref.read(cartProvider.notifier).increment(item.id),
                    onDecrement: () =>
                        ref.read(cartProvider.notifier).decrement(item.id),
                  );
                },
                childCount: vendorItems.length,
              ),
            ),
          ),
    );
  }

  Future<void> _handleAdd(MenuItem item, bool isGuest, CartState cartState) async {
    if (isGuest) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const SignUpToOrderSheet(),
      );
      return;
    }

    final vendorId = item.vendorId ?? '';

    // Fetch the full item detail (includes variants & addons) from the
    // per-item endpoint. Fall back to the catalog item if the call fails.
    MenuItem fullItem = item;
    try {
      fullItem = await ref
          .read(vendorRepositoryProvider)
          .getStoreItem(vendorId, item.id);
    } catch (_) {
      // catalogue item used as fallback — addons may be absent
    }

    if (!mounted) return;

    await ItemAddSheet.show(
      context,
      item: fullItem,
      vendorId: vendorId,
      vendorName: fullItem.vendorDisplayName ?? item.vendorDisplayName ?? vendorId,
      zoneId: '',
    );

    // After the sheet closes, expand this vendor's items if the cart now
    // contains something from it.
    if (!mounted) return;
    final updatedCart = ref.read(cartProvider);
    if (updatedCart.vendorId == vendorId || updatedCart.vendorId == null) {
      setState(() {
        _expandedVendorId = vendorId;
        _expandedVendorName = fullItem.vendorDisplayName ?? item.vendorDisplayName;
      });
    }
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

  Widget _buildSearchItemCard(
    MenuItem item,
    CartState cartState,
    bool isGuest,
  ) {
    final quantity = cartState.items[item.id]?.quantity ?? 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                ? AppImage(
                    item.imageUrl!,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 70,
                    height: 70,
                    color: Colors.grey.shade100,
                    child: Icon(
                      Icons.fastfood_outlined,
                      size: 28,
                      color: Colors.grey.shade400,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: AppText(
                        item.name,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AppText(
                      '₦${item.price.toInt()}',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryOrange,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (item.vendorDisplayName != null)
                  Row(
                    children: [
                      const Icon(
                        Icons.storefront_outlined,
                        size: 12,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: AppSubText(
                          item.vendorDisplayName!,
                          fontSize: 12,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                if (item.category != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: AppText(
                      item.category!,
                      fontSize: 11,
                      color: AppColors.primaryOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                // Add / quantity controls
                Align(
                  alignment: Alignment.centerRight,
                  child: quantity > 0
                      ? _buildQuantityControl(item)
                      : SizedBox(
                          height: 32,
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _handleAdd(item, isGuest, cartState),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryOrange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              elevation: 0,
                            ),
                            icon: const Icon(
                              Icons.add,
                              size: 16,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Add',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityControl(MenuItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => ref.read(cartProvider.notifier).decrement(item.id),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.remove, size: 16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Consumer(
              builder: (_, ref, __) {
                final qty =
                    ref.watch(cartProvider).items[item.id]?.quantity ?? 0;
                return Text(
                  '$qty',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                );
              },
            ),
          ),
          InkWell(
            onTap: () => ref.read(cartProvider.notifier).increment(item.id),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, size: 16),
            ),
          ),
        ],
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
