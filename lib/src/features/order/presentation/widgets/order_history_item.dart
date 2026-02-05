import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/features/order/models/order_model.dart';
import 'package:intl/intl.dart';

class OrderHistoryItem extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onReorder;

  const OrderHistoryItem({
    super.key,
    required this.order,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₦', decimalDigits: 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: AssetImage(order.vendorLogo), // Assuming asset path
                    fit: BoxFit.cover,
                  ),
                ),
                // Fallback icon mostly for development/mocking if asset missing
                child: order.vendorLogo.isEmpty
                    ? const Icon(Icons.store, color: AppColors.slate400)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      order.vendorName,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 4),
                    AppText(
                      order.status,
                      fontSize: 12,
                      color: order.status == 'Delivered'
                          ? AppColors.secondaryGreen
                          : AppColors.errorRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppText(
                    currencyFormat.format(order.price),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryOrange,
                  ),
                  const SizedBox(height: 4),
                  AppText(order.date, fontSize: 12, color: AppColors.slate400),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade100),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppText(
                  order.itemsSummary,
                  fontSize: 13,
                  color: AppColors.slate500,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 36,
                child: OutlinedButton(
                  onPressed: onReorder,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryOrange),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const AppText(
                    "Reorder",
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
