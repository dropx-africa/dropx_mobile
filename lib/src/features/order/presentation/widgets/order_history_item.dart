import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/models/order.dart';
import 'package:dropx_mobile/src/models/order_item.dart';
import 'package:dropx_mobile/src/utils/currency_utils.dart';
import 'package:intl/intl.dart';
import 'package:dropx_mobile/src/features/order/presentation/order_tracking_screen.dart';
import 'package:dropx_mobile/src/features/order/presentation/widgets/order_status_badge.dart';

const _deliveredStates = {'DELIVERED', 'COMPLETED'};

class OrderHistoryItem extends StatelessWidget {
  final Order order;
  final VoidCallback onReorder;

  const OrderHistoryItem({
    super.key,
    required this.order,
    required this.onReorder,
  });

  bool get _isDelivered => _deliveredStates.contains(order.state);

  void _onTap(BuildContext context) {
    if (_isDelivered) {
      showOrderReceiptSheet(context, order);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OrderTrackingScreen(orderId: order.orderId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₦', decimalDigits: 0);
    final totalNaira = CurrencyUtils.koboToNaira(
      int.tryParse(order.totalAmountKobo) ?? 0,
    );

    final itemsSummary = order.items != null && order.items!.isNotEmpty
        ? order.items!.map((i) => '${i.qty}x ${i.name}').join(', ')
        : 'No items';

    final displayDate = order.createdAt != null
        ? DateFormat.yMMMd().format(DateTime.parse(order.createdAt!))
        : '';

    return InkWell(
      onTap: () => _onTap(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
                    color: _isDelivered
                        ? Colors.green.shade50
                        : AppColors.slate200,
                  ),
                  child: Icon(
                    _isDelivered
                        ? Icons.receipt_long
                        : Icons.local_shipping_outlined,
                    color: _isDelivered
                        ? Colors.green.shade400
                        : AppColors.slate400,
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
                    AppText(
                      displayDate,
                      fontSize: 12,
                      color: AppColors.slate400,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: Colors.grey.shade100),
            const SizedBox(height: 8),
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
                // Action hint chip
                _buildActionChip(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionChip(BuildContext context) {
    if (_isDelivered) {
      return _chip(
        icon: Icons.receipt_outlined,
        label: 'Receipt',
        color: Colors.green,
        onTap: () => showOrderReceiptSheet(context, order),
      );
    }

    if (order.state == 'PAYMENT_PENDING' ||
        order.state == 'PLACED' ||
        order.state == 'ACCEPTED' ||
        order.state == 'ARRIVED_PICKUP' ||
        order.state == 'PICKED_UP' ||
        order.state == 'IN_TRANSIT' ||
        order.state == 'ARRIVED_DROPOFF' ||
        order.state == 'VENDOR_ACCEPTED' ||
        order.state == 'READY_FOR_PICKUP') {
      return _chip(
        icon: Icons.location_on_outlined,
        label: 'Track',
        color: AppColors.primaryOrange,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderTrackingScreen(orderId: order.orderId),
          ),
        ),
      );
    }

    // Cancelled / Disputed — reorder
    return _chip(
      icon: Icons.refresh,
      label: 'Reorder',
      color: AppColors.primaryOrange,
      onTap: onReorder,
    );
  }

  Widget _chip({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Receipt bottom sheet ───────────────────────────────────────────────────────

void showOrderReceiptSheet(BuildContext context, Order order) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ReceiptSheet(order: order),
  );
}

class _ReceiptSheet extends StatelessWidget {
  final Order order;
  const _ReceiptSheet({required this.order});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₦', decimalDigits: 0);
    final totalNaira =
        CurrencyUtils.koboToNaira(int.tryParse(order.totalAmountKobo) ?? 0);

    final displayDate = order.createdAt != null
        ? DateFormat('d MMM yyyy, h:mm a')
            .format(DateTime.parse(order.createdAt!).toLocal())
        : '—';

    final items = order.items ?? [];

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.receipt_long,
                      color: Colors.green.shade600,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          'Receipt',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        AppText(
                          'Order #${order.orderId.length > 8 ? order.orderId.substring(0, 8) : order.orderId}',
                          fontSize: 13,
                          color: AppColors.slate400,
                        ),
                      ],
                    ),
                  ),
                  OrderStatusBadge(status: order.state),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Divider(color: Colors.grey.shade100, height: 1),

            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  // Date
                  _row(
                    icon: Icons.calendar_today_outlined,
                    label: 'Date',
                    value: displayDate,
                  ),
                  if (order.deliveryAddress != null &&
                      order.deliveryAddress!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _row(
                      icon: Icons.location_on_outlined,
                      label: 'Delivered to',
                      value: order.deliveryAddress!,
                    ),
                  ],

                  const SizedBox(height: 20),
                  const AppText(
                    'Items',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 10),

                  if (items.isEmpty)
                    AppText(
                      'No item details available',
                      fontSize: 13,
                      color: AppColors.slate400,
                    )
                  else
                    ...items.map((item) => _itemRow(item, currencyFormat)),

                  const SizedBox(height: 16),
                  Divider(color: Colors.grey.shade200),
                  const SizedBox(height: 12),

                  // Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AppText(
                        'Total Paid',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      AppText(
                        currencyFormat.format(totalNaira),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryOrange,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.slate400),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(label, fontSize: 11, color: AppColors.slate400),
              AppText(value, fontSize: 13, fontWeight: FontWeight.w500),
            ],
          ),
        ),
      ],
    );
  }

  Widget _itemRow(OrderItem item, NumberFormat fmt) {
    final lineTotal = CurrencyUtils.koboToNaira(item.unitPriceKobo * item.qty);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.slate50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: AppText(
              '${item.qty}x',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.slate500,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: AppText(item.name, fontSize: 14),
          ),
          AppText(
            fmt.format(lineTotal),
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.slate500,
          ),
        ],
      ),
    );
  }
}
