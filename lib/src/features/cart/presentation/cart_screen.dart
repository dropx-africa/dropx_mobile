import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/features/cart/providers/cart_provider.dart';
import 'package:dropx_mobile/src/core/utils/formatters.dart';
import 'package:dropx_mobile/src/route/page.dart';
import 'package:dropx_mobile/src/utils/app_navigator.dart';
import 'package:dropx_mobile/src/models/vendor_category.dart';
import 'package:dropx_mobile/src/features/parcel/presentation/generic_order_screen.dart';

import 'package:dropx_mobile/src/features/home/data/mock_vendors.dart'; // Import mock data

class CartScreen extends ConsumerWidget {
  final bool isGuest;

  const CartScreen({super.key, this.isGuest = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final cartItemsList = cartState.items.values.toList();
    final totalPrice = cartState.totalPrice;

    // Calculate fees (mock logic for now)
    final deliveryFee = 400.0;
    final serviceFee = 150.0;
    final totalAmount = totalPrice + deliveryFee + serviceFee;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText("My Cart", fontWeight: FontWeight.bold, fontSize: 18),
            const SizedBox(height: 2),
            AppText(
              "Mama Put's Kitchen",
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => AppNavigator.pop(context),
        ),
      ),
      body: cartItemsList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  AppText(
                    "Your cart is empty",
                    color: Colors.grey.shade500,
                    fontSize: 16,
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Address Section
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  AppText(
                                    "DELIVER TO",
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade600,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoute.manualLocation,
                                      );
                                    },
                                    child: const AppText(
                                      "Change",
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryOrange,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Row(
                                children: [
                                  Icon(Icons.location_on_outlined, size: 16),
                                  SizedBox(width: 4),
                                  AppText(
                                    "12 Herbert Macaulay Way, Yaba",
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Cart Items
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: cartItemsList
                                .map((item) => _buildCartItem(ref, item))
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 16), // Bottom padding for list
                      ],
                    ),
                  ),
                ),

                // Bill Details (Sticky Footer)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: AppColors.darkBackground,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildBillRow(
                        "Subtotal",
                        Formatters.formatNaira(totalPrice),
                      ),
                      const SizedBox(height: 12),
                      _buildBillRow(
                        "Delivery Fee",
                        Formatters.formatNaira(deliveryFee),
                      ),
                      const SizedBox(height: 12),
                      _buildBillRow(
                        "Service Fee",
                        Formatters.formatNaira(serviceFee),
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: Colors.grey, thickness: 0.5),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const AppText(
                            "Total",
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          AppText(
                            Formatters.formatNaira(totalAmount),
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Place Order Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (isGuest) {
                              _showLoginRequiredDialog(context);
                            } else {
                              // Determine Order Type based on first item
                              final firstItem = cartItemsList.first.menuItem;
                              OrderType orderType = OrderType.parcel;

                              // Try to find vendor
                              try {
                                final vendor = mockVendors.firstWhere(
                                  (v) => v.id == firstItem.vendorId,
                                  orElse: () => mockVendors.first,
                                );

                                // Check vendor category
                                switch (vendor.category) {
                                  case VendorCategory.parcel:
                                    orderType = OrderType.parcel;
                                    break;
                                  case VendorCategory.pharmacy:
                                    orderType = OrderType.pharmacy;
                                    break;
                                  case VendorCategory.retail:
                                    orderType = OrderType.retail;
                                    break;
                                  default:
                                    // Food or unknown -> Go to normal checkout
                                    Navigator.pushNamed(
                                      context,
                                      AppRoute.orderTracking,
                                    );
                                    return;
                                }
                              } catch (e) {
                                // Fallback if vendor lookup fails
                                Navigator.pushNamed(
                                  context,
                                  AppRoute.orderTracking,
                                );
                                return;
                              }

                              // Prepare pre-filled items string
                              final itemsSummary = cartItemsList
                                  .map(
                                    (i) => "${i.quantity}x ${i.menuItem.name}",
                                  )
                                  .join(", ");

                              Navigator.pushNamed(
                                context,
                                AppRoute.genericOrder,
                                arguments: {
                                  'orderType': orderType,
                                  'preFilledItem': itemsSummary,
                                },
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryOrange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const AppText(
                            "Place Order",
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCartItem(WidgetRef ref, CartItem cartItem) {
    final item = cartItem.menuItem;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: AssetImage(item.imageUrl ?? ''),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      item.name,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    const SizedBox(height: 4),
                    AppText(
                      item.description ?? '',
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    AppText(
                      Formatters.formatNaira(item.price),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ],
                ),
              ),
              // Quantity Controls
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        ref.read(cartProvider.notifier).decrement(item.id);
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Icon(Icons.remove, size: 16),
                      ),
                    ),
                    Text(
                      '${cartItem.quantity}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    InkWell(
                      onTap: () {
                        ref.read(cartProvider.notifier).increment(item.id);
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Icon(Icons.add, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildBillRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(label, color: Colors.grey.shade400, fontSize: 14),
        AppText(
          value,
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ],
    );
  }

  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const AppText("Login Required", fontWeight: FontWeight.bold),
        content: const AppText("Please log in to place an order."),
        actions: [
          TextButton(
            onPressed: () => AppNavigator.pop(context),
            child: const AppText("Cancel", color: Colors.grey),
          ),
          TextButton(
            onPressed: () {
              AppNavigator.pop(context);
              AppNavigator.push(context, AppRoute.login);
            },
            child: const AppText(
              "Login",
              color: AppColors.primaryOrange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
