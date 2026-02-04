import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/features/home/models/vendor_model.dart';
import 'package:dropx_mobile/src/features/home/data/mock_vendors.dart';
import 'package:dropx_mobile/src/features/menu/presentation/widgets/menu_item_card.dart';
import 'package:dropx_mobile/src/features/menu/presentation/widgets/bottom_cart_bar.dart';
import 'package:dropx_mobile/src/features/cart/providers/cart_provider.dart';

class VendorMenuScreen extends ConsumerStatefulWidget {
  final Vendor vendor;
  final bool isGuest;

  const VendorMenuScreen({
    super.key,
    required this.vendor,
    this.isGuest = false,
  });

  @override
  ConsumerState<VendorMenuScreen> createState() => _VendorMenuScreenState();
}

class _VendorMenuScreenState extends ConsumerState<VendorMenuScreen> {
  String _selectedCategory = "All";

  // Mock Categories for now
  final List<String> _categories = [
    "All",
    "Most Popular",
    "Quick Prep",
    "Chef's Specials",
    "Swallow",
    "Rice",
    "Drinks",
  ];

  List<MenuItem> get _filteredItems {
    if (_selectedCategory == "All") {
      return mockMenuItems;
    }
    return mockMenuItems
        .where((item) => item.category == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final cartItems = cartState.items;
    final totalItemCount = cartState.totalItemCount;
    final totalPrice = cartState.totalPrice;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
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
                    onPressed: () => Navigator.pop(context),
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
                      Image.asset(widget.vendor.imageUrl, fit: BoxFit.cover),
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
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: AssetImage(widget.vendor.logoUrl),
                                fit: BoxFit.cover,
                              ),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  widget.vendor.name,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                const SizedBox(height: 4),
                                AppSubText(
                                  widget.vendor.tags.join(" • "),
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
                            '${widget.vendor.rating} (${widget.vendor.ratingCount}+)',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          Container(
                            height: 12,
                            width: 1,
                            color: Colors.grey.shade300,
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          const Icon(
                            Icons.access_time,
                            color: Colors.grey,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          AppText(
                            widget.vendor.deliveryTime,
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                          Container(
                            height: 12,
                            width: 1,
                            color: Colors.grey.shade300,
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          AppText(
                            "₦${widget.vendor.deliveryFee.toInt()}",
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
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final category = _categories[index];
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
                    if (_filteredItems.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(child: Text("No items in this category")),
                      );
                    }
                    final item = _filteredItems[index];
                    final cartItem = cartItems[item.id];
                    final quantity = cartItem?.quantity ?? 0;

                    return MenuItemCard(
                      item: item,
                      quantity: quantity,
                      onAdd: () =>
                          ref.read(cartProvider.notifier).addToCart(item),
                      onIncrement: () =>
                          ref.read(cartProvider.notifier).increment(item.id),
                      onDecrement: () =>
                          ref.read(cartProvider.notifier).decrement(item.id),
                    );
                  },
                  childCount: _filteredItems.isEmpty
                      ? 1
                      : _filteredItems.length,
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
            bottom: totalItemCount > 0
                ? 24
                : -100, // Hide below screen if empty
            left: 16,
            right: 16,
            child: BottomCartBar(
              itemCount: totalItemCount,
              totalPrice: totalPrice,
              isGuest: widget.isGuest,
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
