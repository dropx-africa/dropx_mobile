import 'package:dropx_mobile/src/constants/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/utils/app_navigator.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/app_loading_widget.dart';
import 'package:dropx_mobile/src/common_widgets/app_error_widget.dart';
import 'package:dropx_mobile/src/models/menu_item.dart';
import 'package:dropx_mobile/src/features/menu/presentation/widgets/menu_item_card.dart';
import 'package:dropx_mobile/src/features/menu/presentation/widgets/bottom_cart_bar.dart';
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
  String _selectedCategory = "All";

  List<String> _buildCategories(List<MenuItem> items) {
    final categories = items
        .map((item) => item.category?.name ?? 'Other')
        .toSet()
        .toList();
    return ["All", ...categories];
  }

  List<MenuItem> _filterItems(List<MenuItem> items) {
    if (_selectedCategory == "All") return items;
    return items
        .where((item) => (item.category?.name ?? 'Other') == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionServiceProvider);
    final isGuest = session.isGuest;
    final catalogAsync = ref.watch(storeCatalogProvider(widget.vendorId));
    final cartState = ref.watch(cartProvider);
    final cartItems = cartState.items;
    final totalItemCount = cartState.totalItemCount;
    final totalPrice = cartState.totalPrice;

    return Scaffold(
      backgroundColor: Colors.white,
      body: catalogAsync.when(
        loading: () => const AppLoadingWidget(),
        error: (error, _) => AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(storeCatalogProvider(widget.vendorId)),
        ),
        data: (catalog) {
          final store = catalog.store ?? {};
          final allItems = catalog.items;
          final categories = _buildCategories(allItems);
          final filteredItems = _filterItems(allItems);

          // Extract store info with fallbacks
          final storeName = store['display_name'] as String? ?? 'Store';
          final storeImage = store['image_url'] as String?;
          // final storeLogo = store['logo_url'] as String?;
          final storeTags =
              (store['tags'] as List?)?.cast<String>() ?? ["accuracy"];
          final storeRating = store['rating'] ?? 0;
          final storeRatingCount = store['rating_count'] ?? 0;
          final storeDeliveryTime =
              store['delivery_time'] as String? ?? '9:00AM';
          final storeDeliveryFee = store['delivery_fee'] ?? 0;

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // Sticky App Bar with Image
                  SliverAppBar(
                    pinned: true,
                    expandedHeight: 180,
                    leading: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => AppNavigator.pop(context),
                      ),
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: IconButton(
                            icon: const Icon(Icons.search, color: Colors.black),
                            onPressed: () {},
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

                  // Vendor Info (Scrolls away)
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
                                    const SizedBox(height: 4),
                                    AppSubText(
                                      storeTags.join(" • "),
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: AppColors.primaryOrange,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              AppText(
                                '$storeRating ($storeRatingCount+)',
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              Container(
                                height: 12,
                                width: 1,
                                color: Colors.grey.shade300,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                              ),
                              const Icon(
                                Icons.access_time,
                                color: Colors.grey,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              AppText(
                                storeDeliveryTime,
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                              Container(
                                height: 12,
                                width: 1,
                                color: Colors.grey.shade300,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                              ),
                              AppText(
                                "₦${(storeDeliveryFee?.toInt())}",
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Sticky Tab Bar
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
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedCategory = category;
                                    });
                                  },
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
                                        category,
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

                  // Title for Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        _selectedCategory == "All"
                            ? "All Items"
                            : _selectedCategory,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Menu Items List
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (filteredItems.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Center(
                              child: Text("No items in this category"),
                            ),
                          );
                        }
                        final item = filteredItems[index];
                        final cartItem = cartItems[item.id];
                        final quantity = cartItem?.quantity ?? 0;

                        return MenuItemCard(
                          item: item,
                          quantity: quantity,
                          onAdd: () {
                            if (isGuest) {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) =>
                                    const SignUpToOrderSheet(),
                              );
                            } else {
                              final storeZoneId =
                                  store['zone_id'] as String? ?? '';
                              final result = ref
                                  .read(cartProvider.notifier)
                                  .addToCart(
                                    item,
                                    vendorId: widget.vendorId,
                                    zoneId: storeZoneId,
                                  );

                              if (result == AddToCartResult.vendorConflict) {
                                _showVendorConflictDialog(
                                  context,
                                  ref,
                                  item,
                                  storeZoneId,
                                );
                              }
                            }
                          },
                          onIncrement: () => ref
                              .read(cartProvider.notifier)
                              .increment(item.id),
                          onDecrement: () => ref
                              .read(cartProvider.notifier)
                              .decrement(item.id),
                        );
                      },
                      childCount: filteredItems.isEmpty
                          ? 1
                          : filteredItems.length,
                    ),
                  ),

                  // Bottom padding for FAB or scrolling
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),

              // Floating Cart Bar (Animated)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                bottom: totalItemCount > 0 ? 24 : -100,
                left: 16,
                right: 16,
                child: BottomCartBar(
                  itemCount: totalItemCount,
                  totalPrice: totalPrice,
                  isGuest: isGuest,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showVendorConflictDialog(
    BuildContext context,
    WidgetRef ref,
    MenuItem item,
    String zoneId,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const AppText(
          'Replace cart items?',
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        content: const AppText(
          'Your cart contains items from another vendor. '
          'Would you like to clear the cart and add this item instead?',
          fontSize: 14,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const AppText('Cancel', color: AppColors.slate400),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(cartProvider.notifier)
                  .clearAndAdd(item, vendorId: widget.vendorId, zoneId: zoneId);
            },
            child: const AppText(
              'Clear & Add',
              color: AppColors.primaryOrange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Delegate for Sticky Header
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyTabBarDelegate({required this.child});

  @override
  double get minExtent => 60.0;
  @override
  double get maxExtent => 60.0;

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
    return true;
  }
}
