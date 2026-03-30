import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/app_scaffold.dart';
import 'package:dropx_mobile/src/common_widgets/app_appbar.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/utils/app_navigator.dart';
import 'package:dropx_mobile/src/route/page.dart';
import 'package:dropx_mobile/src/features/cart/providers/cart_provider.dart';
import 'package:dropx_mobile/src/features/order/providers/order_providers.dart';
import 'package:dropx_mobile/src/features/order/presentation/widgets/order_history_item.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);

    return AppScaffold(
      appBar: const AppAppBar(
        title: 'Your Orders',
        style: AppAppBarStyle.white,
        showBack: false,
      ),
      slivers: [
        ordersAsync.when(
          data: (orders) {
            if (orders.isEmpty) {
              return SliverFillRemaining(
                child: Center(
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
                ),
              );
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: OrderHistoryItem(
                    order: orders[index],
                    onReorder: () {
                      final order = orders[index];
                      if (order.items != null && order.items!.isNotEmpty) {
                        ref.read(cartProvider.notifier).reorder(order);
                        AppNavigator.push(context, AppRoute.cart);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Cannot reorder: No items found in this order.',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                );
              }, childCount: orders.length),
            );
          },
          loading: () => const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => SliverFillRemaining(
            child: Center(
              child: AppText(
                'Failed to load orders: $error',
                color: AppColors.errorRed,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
