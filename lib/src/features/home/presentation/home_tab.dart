import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/features/profile/presentation/notifications_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/models/vendor_category.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';

import 'package:dropx_mobile/src/features/home/widgets/category_button.dart';
import 'package:dropx_mobile/src/features/home/widgets/delivery_filter.dart';
import 'package:dropx_mobile/src/features/home/widgets/recent_orders_section.dart';
import 'package:dropx_mobile/src/features/home/widgets/featured_section.dart';
import 'package:dropx_mobile/src/features/home/widgets/fastest_section.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/app_spacers.dart';
import 'package:dropx_mobile/src/route/page.dart';
import 'package:dropx_mobile/src/core/providers/core_providers.dart'; // session provider
import 'package:dropx_mobile/src/features/cart/providers/cart_provider.dart';

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  // Note: ConsumerState gives access to `ref` through ConsumerStatefulWidget
  VendorCategory _selectedCategory = VendorCategory.food; // Default category
  int? _selectedEta; // Filter state for ETA

  @override
  Widget build(BuildContext context) {
    // Watch session provider for the saved address
    final session = ref.watch(sessionServiceProvider);
    final bool isGuest = session.isGuest;
    final String displayAddress = session.savedAddress;

    return Scaffold(
      body: Column(
        children: [
          // Fixed Orange Header
          Container(
            decoration: const BoxDecoration(
              color: AppColors.primaryOrange,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Location and Search Icon Row
                    Row(
                      children: [
                        // Location with category
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              // Navigate to location/manual location screen
                              Navigator.pushNamed(
                                context,
                                AppRoute.manualLocation,
                              );
                            },
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      AppText(
                                        _selectedCategory.name
                                                .substring(0, 1)
                                                .toUpperCase() +
                                            _selectedCategory.name.substring(1),
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      AppText(
                                        displayAddress,
                                        color: Colors.white70,
                                        fontSize: 12,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.notifications_none_rounded,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const NotificationsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    AppSpaces.v16,
                    // Categories
                    SizedBox(
                      height: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CategoryButton(
                            icon: Icons.restaurant,
                            label: 'Food',
                            isSelected:
                                _selectedCategory == VendorCategory.food,
                            onTap: () => setState(() {
                              _selectedCategory = VendorCategory.food;
                              _selectedEta =
                                  null; // Reset filter on category change
                            }),
                          ),
                          CategoryButton(
                            icon: Icons.local_pharmacy,
                            label: 'Pharmacy',
                            isSelected:
                                _selectedCategory == VendorCategory.pharmacy,
                            onTap: () => setState(() {
                              _selectedCategory = VendorCategory.pharmacy;
                              _selectedEta = null;
                            }),
                          ),
                          CategoryButton(
                            icon: Icons.card_giftcard,
                            label: 'Parcel',
                            isSelected:
                                _selectedCategory == VendorCategory.parcel,
                            onTap: () => setState(() {
                              _selectedCategory = VendorCategory.parcel;
                              _selectedEta = null;
                            }),
                          ),
                          CategoryButton(
                            icon: Icons.shopping_cart,
                            label: 'Retail',
                            isSelected:
                                _selectedCategory == VendorCategory.retail,
                            onTap: () => setState(() {
                              _selectedCategory = VendorCategory.retail;
                              _selectedEta = null;
                            }),
                          ),
                        ],
                      ),
                    ),
                    AppSpaces.v8,
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSpaces.v16,
                  DeliveryFilter(
                    selectedEta: _selectedEta,
                    onFilterChanged: (eta) {
                      setState(() {
                        _selectedEta = eta;
                      });
                    },
                  ),
                  AppSpaces.v24,
                  if (!isGuest) const RecentOrdersSection(),
                  FeaturedSection(
                    category: _selectedCategory,
                    maxEtaMinutes: _selectedEta,
                  ),
                  if (_selectedEta == null) ...[
                    AppSpaces.v24,
                    FastestSection(category: _selectedCategory),
                  ],
                  AppSpaces.v24,
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Consumer(
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
