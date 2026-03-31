import 'package:dropx_mobile/src/utils/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/models/vendor_category.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';

import 'package:dropx_mobile/src/features/home/widgets/category_button.dart';
import 'package:dropx_mobile/src/features/home/widgets/recent_orders_section.dart';
import 'package:dropx_mobile/src/features/home/widgets/featured_section.dart';
import 'package:dropx_mobile/src/features/home/widgets/fastest_section.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/app_spacers.dart';
import 'package:dropx_mobile/src/common_widgets/app_scaffold.dart';
import 'package:dropx_mobile/src/route/page.dart';
import 'package:dropx_mobile/src/core/providers/core_providers.dart'; // session provider
import 'package:dropx_mobile/src/features/cart/providers/cart_provider.dart';

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _StickyOrangeHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double safeAreaTop;
  final String displayAddress;
  final bool isGuest;
  final VoidCallback onLocationTap;
  final VoidCallback onNotificationTap;

  const _StickyOrangeHeaderDelegate({
    required this.safeAreaTop,
    required this.displayAddress,
    required this.isGuest,
    required this.onLocationTap,
    required this.onNotificationTap,
  });

  // safeAreaTop + 16(top pad) + 48(row, IconButton min) + 16(spacer) + 16(bottom pad)
  double get _height => safeAreaTop + 98;

  @override
  double get maxExtent => _height;

  @override
  double get minExtent => _height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primaryOrange,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      padding: EdgeInsets.only(
        top: safeAreaTop + 16,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onLocationTap,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: AppText(
                          displayAddress,
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!isGuest)
                IconButton(
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white,
                  ),
                  onPressed: onNotificationTap,
                ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _StickyOrangeHeaderDelegate oldDelegate) =>
      oldDelegate.safeAreaTop != safeAreaTop ||
      oldDelegate.displayAddress != displayAddress ||
      oldDelegate.isGuest != isGuest;
}

class _StickyCategoryDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyCategoryDelegate({required this.child});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  double get maxExtent => 120;

  @override
  double get minExtent => 120;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

class _HomeTabState extends ConsumerState<HomeTab> {
  // Note: ConsumerState gives access to `ref` through ConsumerStatefulWidget
  VendorCategory _selectedCategory = VendorCategory.food; // Default category

  @override
  Widget build(BuildContext context) {
    // Watch session provider for the saved address
    final session = ref.watch(sessionServiceProvider);
    final bool isGuest = session.isGuest;
    final String displayAddress = session.savedAddress;

    final safeAreaTop = MediaQuery.of(context).padding.top;

    return AppScaffold(
      useSafeArea: false,
      slivers: [
        // Fixed Orange Header
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickyOrangeHeaderDelegate(
            safeAreaTop: safeAreaTop,
            displayAddress: displayAddress,
            isGuest: isGuest,
            onLocationTap: () => AppNavigator.push(
              context,
              AppRoute.manualLocation,
            ),
            onNotificationTap: () => AppNavigator.push(
              context,
              AppRoute.notifications,
            ),
          ),
        ),

        // Sticky Categories
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickyCategoryDelegate(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: SizedBox(
                height: 96,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    CategoryButton(
                      icon: Icons.restaurant,
                      label: 'Food',
                      isSelected: _selectedCategory == VendorCategory.food,
                      onTap: () => setState(() {
                        _selectedCategory = VendorCategory.food;
                      }),
                    ),
                    const SizedBox(width: 12),
                    CategoryButton(
                      icon: Icons.local_pharmacy,
                      label: 'Pharmacy',
                      isSelected: _selectedCategory == VendorCategory.pharmacy,
                      onTap: () => setState(() {
                        _selectedCategory = VendorCategory.pharmacy;
                      }),
                    ),
                    const SizedBox(width: 12),
                    CategoryButton(
                      icon: Icons.card_giftcard,
                      label: 'Parcel',
                      isSelected: _selectedCategory == VendorCategory.parcel,
                      onTap: () => setState(() {
                        _selectedCategory = VendorCategory.parcel;
                      }),
                    ),
                    const SizedBox(width: 12),
                    CategoryButton(
                      icon: Icons.shopping_cart,
                      label: 'Retail',
                      isSelected: _selectedCategory == VendorCategory.retail,
                      onTap: () => setState(() {
                        _selectedCategory = VendorCategory.retail;
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Scrollable Content
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSpaces.v16,
              if (!isGuest) const RecentOrdersSection(),
              FeaturedSection(category: _selectedCategory),
              AppSpaces.v24,
              FastestSection(category: _selectedCategory),
              AppSpaces.v24,
            ],
          ),
        ),
      ],
      floatingActionButton: isGuest
          ? null
          : Consumer(
              builder: (context, ref, child) {
                final cartState = ref.watch(cartProvider);
                final int itemCount = cartState.totalItemCount;

                return FloatingActionButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoute.cart),
                  backgroundColor: AppColors.primaryOrange,
                  child: Badge(
                    isLabelVisible: itemCount > 0,
                    label: Text(
                      itemCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: AppColors.errorRed,
                    offset: const Offset(8, -8),
                    child: const Icon(Icons.shopping_cart, color: Colors.white),
                  ),
                );
              },
            ),
    );
  }
}
