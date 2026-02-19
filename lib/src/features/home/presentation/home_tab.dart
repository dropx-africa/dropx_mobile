import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';

import 'package:dropx_mobile/src/features/home/widgets/category_button.dart';
import 'package:dropx_mobile/src/features/home/widgets/delivery_filter.dart';
import 'package:dropx_mobile/src/features/home/widgets/recent_orders_section.dart';
import 'package:dropx_mobile/src/features/home/widgets/featured_section.dart';
import 'package:dropx_mobile/src/features/home/widgets/fastest_section.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/app_spacers.dart';
import 'package:dropx_mobile/src/route/page.dart';

class HomeTab extends StatefulWidget {
  final bool isGuest;

  const HomeTab({super.key, this.isGuest = false});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String _selectedCategory = 'Food'; // Default category

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Fixed Orange Header
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
                                        _selectedCategory,
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      const AppText(
                                        'FJ...04, Lagos, Nigeria',
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search, color: Colors.white),
                          onPressed: () {
                            // Navigate to discover/search screen
                            // TODO: Create search/discover screen
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
                            isSelected: _selectedCategory == 'Food',
                            onTap: () =>
                                setState(() => _selectedCategory = 'Food'),
                          ),
                          CategoryButton(
                            icon: Icons.local_pharmacy,
                            label: 'Pharmacy',
                            isSelected: _selectedCategory == 'Pharmacy',
                            onTap: () =>
                                setState(() => _selectedCategory = 'Pharmacy'),
                          ),
                          CategoryButton(
                            icon: Icons.card_giftcard,
                            label: 'Parcel',
                            isSelected: _selectedCategory == 'Parcel',
                            onTap: () =>
                                setState(() => _selectedCategory = 'Parcel'),
                          ),
                          CategoryButton(
                            icon: Icons.shopping_cart,
                            label: 'Retail',
                            isSelected: _selectedCategory == 'Retail',
                            onTap: () =>
                                setState(() => _selectedCategory = 'Retail'),
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

                  // Delivery Time Filters
                  const DeliveryFilter(),

                  AppSpaces.v24,

                  // Recent Orders (hidden for guests)
                  if (!widget.isGuest) const RecentOrdersSection(),

                  // Featured Section (filtered by category)
                  FeaturedSection(
                    isGuest: widget.isGuest,
                    category: _selectedCategory,
                  ),

                  AppSpaces.v24,

                  // Fastest Section (filtered by category)
                  FastestSection(
                    isGuest: widget.isGuest,
                    category: _selectedCategory,
                  ),

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
