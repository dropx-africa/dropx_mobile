import 'package:flutter/material.dart';
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

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
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
                                // const Icon(
                                //   Icons.keyboard_arrow_down,
                                //   color: Colors.white,
                                //   size: 20,
                                // ),
                              ],
                            ),
                          ),
                        ),
                        // IconButton(
                        //   icon: const Icon(Icons.search, color: Colors.white),
                        //   onPressed: () {
                        //     // Navigate to discover/search screen
                        //   },
                        // ),
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
                            onTap: () => setState(
                              () => _selectedCategory = VendorCategory.food,
                            ),
                          ),
                          CategoryButton(
                            icon: Icons.local_pharmacy,
                            label: 'Pharmacy',
                            isSelected:
                                _selectedCategory == VendorCategory.pharmacy,
                            onTap: () => setState(
                              () => _selectedCategory = VendorCategory.pharmacy,
                            ),
                          ),
                          CategoryButton(
                            icon: Icons.card_giftcard,
                            label: 'Parcel',
                            isSelected:
                                _selectedCategory == VendorCategory.parcel,
                            onTap: () => setState(
                              () => _selectedCategory = VendorCategory.parcel,
                            ),
                          ),
                          CategoryButton(
                            icon: Icons.shopping_cart,
                            label: 'Retail',
                            isSelected:
                                _selectedCategory == VendorCategory.retail,
                            onTap: () => setState(
                              () => _selectedCategory = VendorCategory.retail,
                            ),
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
                  const DeliveryFilter(),
                  AppSpaces.v24,
                  if (!isGuest) const RecentOrdersSection(),
                  FeaturedSection(category: _selectedCategory),
                  AppSpaces.v24,
                  FastestSection(category: _selectedCategory),
                  AppSpaces.v24,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
