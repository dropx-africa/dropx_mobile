import 'package:dropx_mobile/src/utils/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/models/vendor_category.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';

import 'package:dropx_mobile/src/features/home/widgets/recent_orders_section.dart';
import 'package:dropx_mobile/src/features/home/widgets/recent_parcels_section.dart';
import 'package:dropx_mobile/src/features/parcel/providers/parcel_providers.dart';
import 'package:dropx_mobile/src/features/home/widgets/featured_section.dart';
import 'package:dropx_mobile/src/features/home/widgets/fastest_section.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/app_spacers.dart';
import 'package:dropx_mobile/src/common_widgets/app_scaffold.dart';
import 'package:dropx_mobile/src/route/page.dart';
import 'package:dropx_mobile/src/core/providers/core_providers.dart';
import 'package:dropx_mobile/src/features/cart/providers/cart_provider.dart';
import 'package:dropx_mobile/src/features/order/providers/order_providers.dart';
import 'package:dropx_mobile/src/features/home/providers/home_feed_providers.dart';

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

  const _StickyCategoryDelegate({required this.child});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  double get maxExtent => 72;

  @override
  double get minExtent => 72;

  @override
  bool shouldRebuild(covariant _StickyCategoryDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}

class _HomeTabState extends ConsumerState<HomeTab> {
  VendorCategory _selectedCategory = VendorCategory.food;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionServiceProvider);
    final bool isGuest = session.isGuest;
    final String displayAddress = session.savedAddress;

    final safeAreaTop = MediaQuery.of(context).padding.top;

    return AppScaffold(
      useSafeArea: false,
      onRefresh: () async {
        ref.invalidate(ordersProvider);
        ref.invalidate(parcelsProvider);
        ref.invalidate(homeFeedProvider);
      },
      slivers: [
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
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickyCategoryDelegate(
            child: Container(
              color: Colors.white,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _VerticalPill(
                      label: 'Food',
                      icon: Icons.restaurant,
                      isSelected: _selectedCategory == VendorCategory.food,
                      onTap: () => setState(
                        () => _selectedCategory = VendorCategory.food,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _VerticalPill(
                      label: 'Pharmacy',
                      icon: Icons.local_pharmacy,
                      isSelected:
                          _selectedCategory == VendorCategory.pharmacy,
                      onTap: () => setState(
                        () => _selectedCategory = VendorCategory.pharmacy,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _VerticalPill(
                      label: 'Retail',
                      icon: Icons.shopping_bag_outlined,
                      isSelected: _selectedCategory == VendorCategory.retail,
                      onTap: () => setState(
                        () => _selectedCategory = VendorCategory.retail,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _VerticalPill(
                      label: 'Send Parcel',
                      icon: Icons.local_shipping_outlined,
                      isSelected: false,
                      isAction: true,
                      onTap: () =>
                          AppNavigator.push(context, AppRoute.parcel),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSpaces.v16,
              if (!isGuest) ...[
                const RecentOrdersSection(),
                const RecentParcelsSection(),
              ],
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

class _VerticalPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final bool isAction;
  final VoidCallback onTap;

  const _VerticalPill({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.isAction = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg = isAction
        ? AppColors.primaryOrange
        : isSelected
            ? AppColors.primaryOrange
            : Colors.grey.shade100;

    final Color fg = (isAction || isSelected) ? Colors.white : Colors.black87;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(50),
          boxShadow: isSelected || isAction
              ? [
                  BoxShadow(
                    color: AppColors.primaryOrange.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: fg, size: 18),
            const SizedBox(width: 6),
            AppText(
              label,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ],
        ),
      ),
    );
  }
}