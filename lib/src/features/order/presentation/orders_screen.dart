import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/features/order/models/order_model.dart';
import 'package:dropx_mobile/src/features/order/presentation/widgets/order_history_item.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  final List<OrderModel> _orders = const [
    OrderModel(
      id: '1',
      vendorName: 'Mama Put',
      vendorLogo:
          'assets/images/food_placeholder.png', // Ensure this exists or handle error
      itemsSummary: '2x Jollof Rice, 1x Fried Plantain, 1x Grilled Chicken',
      date: 'Today, 12:30 PM',
      price: 4500,
      status: 'Delivered',
    ),
    OrderModel(
      id: '2',
      vendorName: 'Chicken Republic',
      vendorLogo: 'assets/images/food_placeholder.png',
      itemsSummary: '1x Refuel Combo, 1x Coke (50cl)',
      date: 'Yesterday, 6:45 PM',
      price: 3200,
      status: 'Delivered',
    ),
    OrderModel(
      id: '3',
      vendorName: 'MedPlus Pharmacy',
      vendorLogo: 'assets/images/pharmacy_placeholder.png',
      itemsSummary: '1x Panadol Extra, 1x Vitamin C',
      date: 'Mon, 10:15 AM',
      price: 1800,
      status: 'Cancelled',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const AppText(
          "Your Orders",
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: false,
        automaticallyImplyLeading: false, // Hide back button for tab
      ),
      body: _orders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: AppColors.slate200,
                  ),
                  const SizedBox(height: 16),
                  const AppText(
                    "No orders yet",
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 8),
                  AppText(
                    "Your order history will appear here",
                    color: AppColors.slate400,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                return OrderHistoryItem(
                  order: _orders[index],
                  onReorder: () {
                    // TODO: Implement Reorder Logic (Add to cart)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Reordering... Added to cart'),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
