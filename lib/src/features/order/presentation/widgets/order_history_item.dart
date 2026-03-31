import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/models/order.dart';
import 'package:dropx_mobile/src/utils/currency_utils.dart';
import 'package:intl/intl.dart';
import 'package:dropx_mobile/src/features/order/presentation/order_tracking_screen.dart';
import 'package:dropx_mobile/src/features/order/presentation/widgets/order_status_badge.dart';

class OrderHistoryItem extends StatelessWidget {
  final Order order;
  final VoidCallback onReorder;

  const OrderHistoryItem({
    super.key,
    required this.order,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₦', decimalDigits: 0);
    final totalNaira = CurrencyUtils.koboToNaira(
      int.tryParse(order.totalAmountKobo) ?? 0,
    );

    // Build items summary text from order items
    final itemsSummary = order.items != null && order.items!.isNotEmpty
        ? order.items!.map((i) => '${i.qty}x ${i.name}').join(', ')
        : 'No items';

    // Format date
    final displayDate = order.createdAt != null
        ? DateFormat.yMMMd().format(DateTime.parse(order.createdAt!))
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.slate200,
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: AppColors.slate400,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      'Order #${order.orderId.substring(0, 8)}',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 4),
                    OrderStatusBadge(status: order.state),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppText(
                    currencyFormat.format(totalNaira),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryOrange,
                  ),
                  const SizedBox(height: 4),
                  AppText(displayDate, fontSize: 12, color: AppColors.slate400),
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
                  itemsSummary,
                  fontSize: 13,
                  color: AppColors.slate500,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              if (order.state == 'PAID' ||
                  (order.state != 'PAYMENT_PENDING' &&
                      order.state != 'PLACED' &&
                      order.state !=
                          'DRAFT' && // Accommodating the user's typo exception
                      order.state != 'DELIVERED' &&
                      order.state != 'CANCELLED' &&
                      order.state != 'COMPLETED'))
                Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                OrderTrackingScreen(orderId: order.orderId),
                          ),
                        );
                      },
                      icon: const Icon(Icons.location_on),
                      color: AppColors.primaryOrange,
                      tooltip: 'Track Order',
                    ),
                  ),
                ),
              if (order.state == 'COMPLETED')
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: onReorder,
                    icon: const Icon(Icons.refresh),
                    color: AppColors.primaryOrange,
                    tooltip: 'Reorder',
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
