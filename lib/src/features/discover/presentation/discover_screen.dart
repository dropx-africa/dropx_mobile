import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/app_text_field.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/models/vendor.dart';
import 'package:dropx_mobile/src/models/vendor_category.dart';

import 'package:dropx_mobile/src/features/home/providers/home_feed_providers.dart';
import 'package:dropx_mobile/src/features/vendor/providers/vendor_providers.dart';
import 'package:dropx_mobile/src/features/menu/presentation/widgets/menu_item_card.dart';
import 'package:dropx_mobile/src/route/page.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Food',
    'Pharmacy',
    'Parcel',
    'Retail',
  ];

  VendorCategory? _categoryFromString(String cat) {
    switch (cat) {
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const AppText(
          "Discover",
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppTextField(
              hintText: "Search for anything",
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          const SizedBox(height: 16),

          // Categories Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: AppText(
                      category,
                      color: isSelected
                          ? Colors.white
                          : AppColors.darkBackground,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    selectedColor: AppColors.primaryOrange,
                    backgroundColor: AppColors.slate50,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // List results
          Expanded(
            child: _searchQuery.isEmpty
                ? ref
                      .watch(vendorsProvider(null))
                      .when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (error, _) => Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: AppColors.slate200,
                              ),
                              const SizedBox(height: 12),
                              const AppText(
                                'Failed to load vendors',
                                color: AppColors.slate400,
                              ),
                            ],
                          ),
                        ),
                        data: (vendors) {
                          // Note: For empty query, we are relying on vendorsProvider which fetches /vendors.
                          // It does fetch all vendors. We can still filter them locally by category
                          // to keep the immediate snappy category change.
                          final selectedCat = _categoryFromString(
                            _selectedCategory,
                          );
                          final filtered = selectedCat != null
                              ? vendors
                                    .where((v) => v.category == selectedCat)
                                    .toList()
                              : vendors;

                          if (filtered.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.store_outlined,
                                    size: 64,
                                    color: AppColors.slate200,
                                  ),
                                  const SizedBox(height: 16),
                                  const AppText(
                                    'No vendors found',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  const SizedBox(height: 8),
                                  const AppText(
                                    'No vendors in this category yet',
                                    color: AppColors.slate400,
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              return _buildVendorCard(filtered[index]);
                            },
                          );
                        },
                      )
                : ref
                      .watch(
                        searchProvider(
                          FeedParams(
                            q: _searchQuery,
                            category: _categoryFromString(
                              _selectedCategory,
                            )?.name,
                          ),
                        ),
                      )
                      .when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (error, _) => Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: AppColors.slate200,
                              ),
                              const SizedBox(height: 12),
                              const AppText(
                                'Failed to load search results',
                                color: AppColors.slate400,
                              ),
                            ],
                          ),
                        ),
                        data: (searchData) {
                          final vendors = searchData.vendors;
                          final items = searchData.items;

                          if (vendors.isEmpty && items.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 64,
                                    color: AppColors.slate200,
                                  ),
                                  const SizedBox(height: 16),
                                  const AppText(
                                    'No results found',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  const SizedBox(height: 8),
                                  const AppText(
                                    'Try a different search term',
                                    color: AppColors.slate400,
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            children: [
                              if (vendors.isNotEmpty) ...[
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 8.0),
                                  child: AppText(
                                    'Vendors',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                ...vendors.map((v) => _buildVendorCard(v)),
                              ],
                              if (items.isNotEmpty) ...[
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: AppText(
                                    'Items',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // We use the MenuItemCard for menu items
                                ...items.map(
                                  (item) => Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 16.0,
                                    ),
                                    child: MenuItemCard(item: item),
                                  ),
                                ),
                              ],
                            ],
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildVendorCard(Vendor vendor) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoute.vendorMenu,
          arguments: {'vendorId': vendor.id},
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vendor image
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.slate200,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                image: vendor.imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(vendor.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: vendor.imageUrl == null
                  ? Center(
                      child: Icon(
                        Icons.store,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                    )
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: AppText(
                          vendor.name,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (vendor.rating != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 12,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                vendor.rating!.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (vendor.category != null)
                        AppText(
                          '${vendor.category!.name[0].toUpperCase()}${vendor.category!.name.substring(1)}',
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      if (vendor.deliveryTime != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        AppText(
                          vendor.deliveryTime!,
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ],
                      if (vendor.deliveryFee != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '₦${vendor.deliveryFee!.toInt()} delivery',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
