import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/custom_button.dart';
import 'package:dropx_mobile/src/common_widgets/app_spacers.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/core/utils/formatters.dart';
import 'package:dropx_mobile/src/utils/currency_utils.dart';
import 'package:dropx_mobile/src/features/order/providers/order_providers.dart';
import 'package:dropx_mobile/src/models/order.dart';
import 'package:dropx_mobile/src/models/order_item.dart';
import 'package:dropx_mobile/src/route/page.dart';

class ReceiptScreen extends ConsumerWidget {
  final Map<String, dynamic> orderDetails;

  const ReceiptScreen({super.key, required this.orderDetails});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderId = orderDetails['orderId'] as String?;

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
      body: orderId == null
          ? _buildError(context, 'No order ID provided')
          : ref.watch(orderByIdProvider(orderId)).when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primaryOrange),
              ),
              error: (_, __) => _buildError(context, 'Could not load receipt'),
              data: (order) => _buildReceipt(context, order),
            ),
    );
  }

  Widget _buildReceipt(BuildContext context, Order order) {
    final items = order.items ?? [];

    final subtotalKobo = items.fold<int>(
      0,
      (sum, item) => sum + item.qty * item.unitPriceKobo,
    );
    final totalKobo = int.tryParse(order.totalAmountKobo) ?? subtotalKobo;
    final feesKobo = (totalKobo - subtotalKobo).clamp(0, totalKobo);

    final subtotal = CurrencyUtils.koboToNaira(subtotalKobo);
    final fees = CurrencyUtils.koboToNaira(feesKobo);
    final total = CurrencyUtils.koboToNaira(totalKobo);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Success header
                Center(
                  child: Column(
                    children: [
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
                      AppText(
                        "Order #${order.orderId}",
                        color: Colors.grey.shade500,
                        fontSize: 13,
                      ),
                    ],
                  ),
                ),

                AppSpaces.v24,
                const Divider(),
                AppSpaces.v16,

                // Items list
                if (items.isNotEmpty) ...[
                  const AppText(
                    "Items Ordered",
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  AppSpaces.v12,
                  ...items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _buildItemRow(item),
                      )),
                  AppSpaces.v16,
                  const Divider(),
                  AppSpaces.v16,
                ],

                // Bill breakdown
                _buildBillRow("Subtotal", Formatters.formatNaira(subtotal)),
                AppSpaces.v12,
                _buildBillRow(
                  "Delivery & Service Fees",
                  Formatters.formatNaira(fees),
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
        ],
      ),
    );
  }

  Widget _buildItemRow(OrderItem item) {
    final lineTotal = CurrencyUtils.koboToNaira(item.qty * item.unitPriceKobo);
    return Row(
      children: [
        Expanded(
          child: AppText(
            "${item.name} × ${item.qty}",
            color: Colors.grey.shade700,
            fontSize: 14,
          ),
        ),
        AppText(
          Formatters.formatNaira(lineTotal),
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ],
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

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppText(message, color: Colors.grey.shade600),
            AppSpaces.v24,
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
          ],
        ),
      ),
    );
  }
}
