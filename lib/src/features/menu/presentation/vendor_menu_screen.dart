import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/constants/app_icons.dart';
import 'package:dropx_mobile/src/utils/currency_utils.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/app_loading_widget.dart';
import 'package:dropx_mobile/src/common_widgets/app_error_widget.dart';
import 'package:dropx_mobile/src/common_widgets/app_search_bar.dart';
import 'package:dropx_mobile/src/common_widgets/app_back_button.dart';
import 'package:dropx_mobile/src/common_widgets/app_scaffold.dart';
import 'package:dropx_mobile/src/models/menu_item.dart';
import 'package:dropx_mobile/src/features/menu/presentation/widgets/menu_item_card.dart';
import 'package:dropx_mobile/src/features/menu/presentation/widgets/bottom_cart_bar.dart';
import 'package:dropx_mobile/src/features/menu/presentation/widgets/item_add_sheet.dart';
import 'package:dropx_mobile/src/features/cart/providers/cart_provider.dart';
import 'package:dropx_mobile/src/features/auth/presentation/sign_up_to_order_sheet.dart';
import 'package:dropx_mobile/src/features/vendor/providers/vendor_providers.dart';
import 'package:dropx_mobile/src/core/providers/core_providers.dart';

class VendorMenuScreen extends ConsumerStatefulWidget {
  final String vendorId;

  const VendorMenuScreen({super.key, required this.vendorId});

  @override
  ConsumerState<VendorMenuScreen> createState() => _VendorMenuScreenState();
}

class _VendorMenuScreenState extends ConsumerState<VendorMenuScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isSearching = false;

  List<String> _buildCategories(List<MenuItem> items) {
    final cats = items.map((item) => item.category ?? 'Other').toSet().toList();
    return ['All', ...cats];
  }

  List<MenuItem> _filterItems(List<MenuItem> items) {
    var filtered = items;
    if (_selectedCategory != 'All') {
      filtered = filtered
          .where((item) => (item.category ?? 'Other') == _selectedCategory)
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (item) =>
                item.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionServiceProvider);
    final isGuest = session.isGuest;
    final catalogAsync = ref.watch(storeCatalogProvider(widget.vendorId));
    final cartState = ref.watch(cartProvider);

    return Stack(
      children: [
        AppScaffold(
          useSafeArea: false,
          slivers: [
            catalogAsync.when(
          loading: () => const SliverFillRemaining(
            child: AppLoading(),
          ),
          error: (error, _) => SliverFillRemaining(
            child: AppErrorWidget(
              message: error.toString(),
              onRetry: () => ref.invalidate(storeCatalogProvider(widget.vendorId)),
            ),
          ),
          data: (catalog) {
            final store = catalog.store;
            final allItems = catalog.items;
            final categories = _buildCategories(allItems);
            final filteredItems = _filterItems(allItems);

            final storeName = store['display_name'] as String? ?? 'Store';
            final storeImage = store['image_url'] as String?;
            final storeTags = (store['tags'] as List?)?.cast<String>() ?? [];
            final storeRating = store['rating'];
            final deliveryFeeKobo = store['delivery_fee_kobo'];
            final distanceKm = (store['distance_km'] as num?)?.toDouble();
            final etaMinutes = store['eta_minutes'] as int?;
            final isOpen = store['is_open'] as bool? ?? true;
            final isAcceptingOrders =
                store['is_accepting_orders'] as bool? ?? true;
            final closedReason = store['closed_reason'] as String?;
            final opensAt = store['opens_at'] as String?;
            final canOrder = isOpen && isAcceptingOrders;

            return SliverMainAxisGroup(
              slivers: [
                // Hero app bar
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 200,
                  leading: const Padding(
                    padding: EdgeInsets.all(8),
                    child: AppBackButton(),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: Icon(
                            _isSearching ? Icons.close : Icons.search,
                            color: Colors.black,
                          ),
                          onPressed: () => setState(() {
                            _isSearching = !_isSearching;
                            if (!_isSearching) _searchQuery = '';
                          }),
                        ),
                      ),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        storeImage != null
                            ? Image.network(
                                storeImage,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Image.asset(
                                  AppIcon.vendorBanner,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Image.asset(
                                AppIcon.vendorBanner,
                                fit: BoxFit.cover,
                              ),
                        // Gradient overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.4),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Store info
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    storeName,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  if (storeTags.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    AppSubText(
                                      storeTags.join(' • '),
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            // Open / Closed badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isOpen
                                    ? Colors.green.shade50
                                    : Colors.red.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: isOpen
                                          ? Colors.green
                                          : Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  AppText(
                                    isOpen ? 'Open' : 'Closed',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isOpen ? Colors.green : Colors.red,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Meta row: rating · distance · eta · delivery fee
                        Wrap(
                          spacing: 12,
                          runSpacing: 6,
                          children: [
                            if (storeRating != null)
                              _metaItem(
                                Icons.star,
                                '${storeRating is double ? storeRating.toStringAsFixed(1) : storeRating}',
                                color: AppColors.primaryOrange,
                              ),
                            if (distanceKm != null)
                              _metaItem(
                                Icons.place_outlined,
                                '${distanceKm.toStringAsFixed(1)} km',
                              ),
                            if (etaMinutes != null)
                              _metaItem(Icons.access_time, '$etaMinutes min'),
                            _metaItem(
                              Icons.delivery_dining,
                              CurrencyUtils.formatKoboAsNaira(
                                deliveryFeeKobo,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Closed / not-accepting banner
                if (!canOrder)
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.red.shade700,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AppText(
                              _buildClosedMessage(
                                isOpen: isOpen,
                                closedReason: closedReason,
                                opensAt: opensAt,
                              ),
                              fontSize: 13,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Sticky category tab bar
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyTabBarDelegate(
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: SizedBox(
                        height: 36,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            final isSelected = category == _selectedCategory;
                            final label = category.isEmpty
                                ? category
                                : '${category[0].toUpperCase()}${category.substring(1)}';
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () => setState(
                                  () => _selectedCategory = category,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primaryOrange
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primaryOrange
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      label,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                // Inline search bar (toggled)
                if (_isSearching)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: AppSearchBar(
                        hintText: 'Search menu...',
                        onChanged: (val) =>
                            setState(() => _searchQuery = val),
                      ),
                    ),
                  ),

                // Section title
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: AppText(
                      _selectedCategory == 'All'
                          ? 'All Menu Items'
                          : _selectedCategory,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Menu items
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (filteredItems.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(
                            child: AppText('No items in this category'),
                          ),
                        );
                      }
                      final item = filteredItems[index];
                      final quantity =
                          cartState.items[item.id]?.quantity ?? 0;

                      return MenuItemCard(
                        item: item,
                        quantity: quantity,
                        onAdd: canOrder
                            ? () async {
                                if (isGuest) {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (_) =>
                                        const SignUpToOrderSheet(),
                                  );
                                  return;
                                }
                                final zoneId =
                                    store['zone_id'] as String? ?? '';
                                // Fetch full item detail (includes addons & variants)
                                MenuItem fullItem = item;
                                try {
                                  fullItem = await ref
                                      .read(vendorRepositoryProvider)
                                      .getStoreItem(widget.vendorId, item.id);
                                } catch (_) {
                                  // Fall back to catalog item if fetch fails
                                }
                                if (!context.mounted) return;
                                ItemAddSheet.show(
                                  context,
                                  item: fullItem,
                                  vendorId: widget.vendorId,
                                  vendorName: storeName,
                                  zoneId: zoneId,
                                );
                              }
                            : null,
                        onIncrement: canOrder
                            ? () => ref
                                  .read(cartProvider.notifier)
                                  .increment(item.id)
                            : null,
                        onDecrement: canOrder
                            ? () => ref
                                  .read(cartProvider.notifier)
                                  .decrement(item.id)
                            : null,
                      );
                    },
                    childCount: filteredItems.isEmpty
                        ? 1
                        : filteredItems.length,
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          },
        ),

      ],
        ),

        // Floating cart bar — fixed at the bottom, overlays the scroll content
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

  String _buildClosedMessage({
    required bool isOpen,
    String? closedReason,
    String? opensAt,
  }) {
    String base;
    if (closedReason?.isNotEmpty == true) {
      base = closedReason!;
    } else if (!isOpen) {
      base = 'This store is currently closed.';
    } else {
      base = 'This store is not accepting orders right now.';
    }
    if (opensAt != null && opensAt.isNotEmpty) {
      base += ' Opens at $opensAt.';
    }
    return base;
  }

  Widget _metaItem(IconData icon, String label, {Color? color}) {
    final c = color ?? Colors.grey.shade700;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: c),
        const SizedBox(width: 4),
        AppText(label, fontSize: 13, color: c),
      ],
    );
  }

}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  const _StickyTabBarDelegate({required this.child});

  @override
  double get minExtent => 60;

  @override
  double get maxExtent => 60;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
