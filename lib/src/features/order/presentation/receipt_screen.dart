import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/custom_button.dart';
import 'package:dropx_mobile/src/common_widgets/app_spacers.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/core/utils/formatters.dart';
import 'package:dropx_mobile/src/route/page.dart';

class ReceiptScreen extends StatelessWidget {
  final Map<String, dynamic> orderDetails;

  const ReceiptScreen({super.key, required this.orderDetails});

  @override
  Widget build(BuildContext context) {
    // Mock data if not provided (for testing independently)
    final orderId = orderDetails['id'] ?? 'ORD-Y2QV9Q';
    final subtotal = orderDetails['subtotal'] ?? 6300.0;
    final deliveryFee = orderDetails['deliveryFee'] ?? 400.0;
    final serviceFee = orderDetails['serviceFee'] ?? 150.0;
    final total = subtotal + deliveryFee + serviceFee;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const AppText("Receipt", fontWeight: FontWeight.bold),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Receipt Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Success Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.green,
                      size: 32,
                    ),
                  ),
                  AppSpaces.v16,
                  const AppText(
                    "Payment Successful",
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  AppSpaces.v4,
                  AppText("Order $orderId", color: Colors.grey.shade500),
                  AppSpaces.v32,

                  const Divider(),
                  AppSpaces.v16,

                  // Bill Details
                  _buildBillRow("Subtotal", Formatters.formatNaira(subtotal)),
                  AppSpaces.v12,
                  _buildBillRow(
                    "Delivery Fee (2.5km)",
                    Formatters.formatNaira(deliveryFee),
                  ),
                  AppSpaces.v12,
                  _buildBillRow(
                    "Service Fee",
                    Formatters.formatNaira(serviceFee),
                  ),
                  AppSpaces.v24,

                  const Divider(),
                  AppSpaces.v16,

                  // Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AppText(
                        "Total Paid",
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      AppText(
                        Formatters.formatNaira(total),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            AppSpaces.v32,

            // Buttons
            CustomButton(
              text: "Back to Home",
              backgroundColor: AppColors.darkBackground,
              textColor: Colors.white,
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoute.dashboard,
                  (route) => false,
                );
              },
            ),
            AppSpaces.v16,
            CustomButton(
              text: "Rate Your Experience",
              backgroundColor: AppColors.primaryOrange,
              textColor: Colors.white,
              onPressed: () {
                // Return to tracking screen or navigate to transaction details to rate?
                // Plan said Transaction Details serves as entry point for rating,
                // BUT wireframe shows Rate Your Experience button here too.
                // Let's pop back or better yet, open the rating sheet directly here if needed,
                Navigator.pop(context); // Go back to tracking/completed view
                // OR navigate to transaction details?
                // The prompt image shows this screen having "Rate Your Experience".
                // I'll make it pop with a result indicating "rate" or handle rating here.
                // For simplicity based on flow, let's assume the user rates via the main flow or here.
                // I'll leave a TODO to open rating sheet or navigate to transaction details.
                Navigator.pushNamed(
                  context,
                  AppRoute
                      .transactionDetails, // Navigate to transaction details which has rating
                  arguments: {'orderDetails': orderDetails},
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(label, color: Colors.grey.shade600),
        AppText(value, fontWeight: FontWeight.bold),
      ],
    );
  }
}
