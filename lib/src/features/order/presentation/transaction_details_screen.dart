import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/custom_button.dart';
import 'package:dropx_mobile/src/common_widgets/app_spacers.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/features/order/presentation/widgets/rating_sheet.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> orderDetails;

  const TransactionDetailsScreen({super.key, required this.orderDetails});

  @override
  Widget build(BuildContext context) {
    // Mock Data
    final orderId = orderDetails['id'] ?? 'TXN-789456123';
    final items = [
      {'name': 'Jollof Rice & Chicken', 'qty': 2, 'price': 2500.0},
      {'name': 'Moi Moi', 'qty': 1, 'price': 800.0},
    ];
    final subtotal = 5800.0;
    final deliveryFee = 400.0;
    final serviceFee = 150.0;
    final discount = 0.0; // -200 in mock?
    final total = subtotal + deliveryFee + serviceFee - discount;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const AppText(
          "Transaction Details",
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Status Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: AppColors.secondaryGreen,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  AppSpaces.v16,
                  const AppText(
                    "Order Completed!",
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  AppSpaces.v8,
                  const AppText(
                    "Delivered at 2:42 PM",
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  AppSpaces.v4,
                  AppText(
                    "Transaction ID: $orderId",
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ],
              ),
            ),
            AppSpaces.v24,

            // Order Summary
            _buildSection(
              title: "Order Summary",
              child: Column(
                children: [
                  ...items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                item['name'] as String,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              AppSpaces.v4,
                              AppText(
                                "Qty: ${item['qty']} × ₦${(item['price'] as double).toInt()}",
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                              const AppText(
                                "Mama Put's Kitchen",
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                          AppText(
                            "₦${((item['price'] as double) * (item['qty'] as int)).toInt()}",
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
                  AppSpaces.v16,
                  _buildRow("Subtotal", "₦${subtotal.toInt()}"),
                  AppSpaces.v8,
                  _buildRow("Delivery Fee", "₦${deliveryFee.toInt()}"),
                  AppSpaces.v8,
                  _buildRow("Service Fee", "₦${serviceFee.toInt()}"),
                  if (discount > 0) ...[
                    AppSpaces.v8,
                    _buildRow(
                      "Discount",
                      "-₦${discount.toInt()}",
                      color: Colors.green,
                    ),
                  ],
                  AppSpaces.v16,
                  const Divider(),
                  AppSpaces.v16,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AppText(
                        "Total Paid",
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      AppText(
                        "₦${total.toInt()}",
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.primaryOrange,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            AppSpaces.v16,

            // Payment Details
            _buildSection(
              title: "Payment Details",
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.credit_card, color: Colors.grey),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AppText(
                            "Credit Card",
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          AppText(
                            "**** **** **** 4829",
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const AppText(
                          "Paid",
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                      AppSpaces.v4,
                      const AppText(
                        "02:42 PM",
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            AppSpaces.v16,

            // Delivery Details
            _buildSection(
              title: "Delivery Details",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage('assets/images/user.png'),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AppText(
                            "Emmanuel O.",
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          Row(
                            children: const [
                              Icon(
                                Icons.star,
                                color: AppColors.warningAmber,
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              AppText(
                                "4.9 Rating",
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  AppSpaces.v24,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AppText(
                              "Pickup",
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            const AppText(
                              "Mama Put's Kitchen, 45 Montgomery Rd, Yaba",
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            AppSpaces.v32,

            // Rate Order Button
            CustomButton(
              text: "Rate Order",
              backgroundColor: AppColors.primaryOrange,
              textColor: Colors.white,
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const RatingSheet(),
                );
              },
            ),
            AppSpaces.v24,
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(title, fontWeight: FontWeight.bold, fontSize: 16),
          const Divider(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(label, color: Colors.grey.shade600, fontSize: 14),
        AppText(
          value,
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: color ?? Colors.black,
        ),
      ],
    );
  }
}
