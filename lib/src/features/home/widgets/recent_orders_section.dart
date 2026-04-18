import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/features/order/providers/order_providers.dart';
import 'package:dropx_mobile/src/features/order/presentation/order_tracking_screen.dart';
import 'package:dropx_mobile/src/features/order/presentation/widgets/order_history_item.dart'
    show showOrderReceiptSheet;
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/models/order.dart';
import 'package:dropx_mobile/src/features/order/presentation/widgets/order_status_badge.dart';

const _deliveredStates = {'DELIVERED', 'COMPLETED'};

String _timeAgo(String? createdAt) {
  if (createdAt == null) return '';
  final dt = DateTime.tryParse(createdAt)?.toLocal();
  if (dt == null) return '';
  final diff = DateTime.now().difference(dt);
  if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${(diff.inDays / 7).floor()}w ago';
}

void _handleOrderTap(BuildContext context, Order order) {
  if (_deliveredStates.contains(order.state)) {
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

class RecentOrdersSection extends ConsumerWidget {
  const RecentOrdersSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);

    return ordersAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          height: 100,
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (orders) {
        if (orders.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText(
                  'Recent Orders',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 40,
                        color: AppColors.slate200,
                      ),
                      const SizedBox(height: 8),
                      AppText(
                        'No orders yet',
                        fontSize: 14,
                        color: AppColors.slate400,
                      ),
                      const SizedBox(height: 4),
                      AppText(
                        'Your recent orders will appear here',
                        fontSize: 12,
                        color: AppColors.slate400,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        }

        final recentOrders = orders.take(5).toList();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppText(
                'Recent Orders',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: recentOrders.length,
                  itemBuilder: (context, index) {
                    final order = recentOrders[index];
                    final isDelivered = _deliveredStates.contains(order.state);

                    return GestureDetector(
                      onTap: () => _handleOrderTap(context, order),
                      child: Container(
                        width: 210,
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDelivered
                                ? Colors.green.shade100
                                : Colors.grey.shade100,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: AppText(
                                    'Order #${order.orderId.length > 8 ? order.orderId.substring(0, 8) : order.orderId}',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                Icon(
                                  isDelivered
                                      ? Icons.receipt_outlined
                                      : Icons.chevron_right,
                                  size: 16,
                                  color: isDelivered
                                      ? Colors.green
                                      : AppColors.slate400,
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            OrderStatusBadge(status: order.state),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AppText(
                                  _timeAgo(order.createdAt),
                                  fontSize: 11,
                                  color: AppColors.slate400,
                                ),
                                AppText(
                                  isDelivered ? 'View receipt' : 'Track →',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDelivered
                                      ? Colors.green
                                      : AppColors.primaryOrange,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
