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
import 'package:dropx_mobile/src/models/order.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  final _scrollController = ScrollController();

  List<Order> _orders = [];
  String? _nextCursor;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_nextCursor == null || _isLoadingMore) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = ref.read(orderRepositoryProvider);
      final response = await repo.getOrders();
      if (mounted) {
        setState(() {
          _orders = response.orders;
          _nextCursor = response.nextCursor;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _reload() async {
    setState(() {
      _orders = [];
      _nextCursor = null;
      _error = null;
    });
    await _load();
    ref.invalidate(ordersProvider);
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _nextCursor == null) return;
    setState(() => _isLoadingMore = true);
    try {
      final repo = ref.read(orderRepositoryProvider);
      final response = await repo.getOrders(cursor: _nextCursor);
      if (mounted) {
        setState(() {
          _orders.addAll(response.orders);
          _nextCursor = response.nextCursor;
          _isLoadingMore = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      controller: _scrollController,
      onRefresh: _reload,
      appBar: AppAppBar(
        title: 'Food Orders',
        showBack: false,
        actions: [
       IconButton(
  icon: const Icon(
    Icons.refresh,
    color: Colors.white,
  ),
  tooltip: 'Retry',
  onPressed: _isLoading ? null : _reload,
),
        ],
      ),
      slivers: [
        if (_isLoading)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_error != null)
          SliverFillRemaining(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 56,
                      color: AppColors.slate200,
                    ),
                    const SizedBox(height: 16),
                    const AppText(
                      'Failed to load orders',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 8),
                    AppText(
                      _error!,
                      fontSize: 13,
                      color: AppColors.slate400,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _load,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else if (_orders.isEmpty)
          SliverFillRemaining(
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
                    'No orders yet',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 8),
                  const AppText(
                    'Your order history will appear here',
                    color: AppColors.slate400,
                  ),
                ],
              ),
            ),
          )
        else ...[
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: OrderHistoryItem(
                  order: _orders[index],
                  onReorder: () {
                    final order = _orders[index];
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
              ),
              childCount: _orders.length,
            ),
          ),
          if (_isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            ),
          if (_nextCursor == null && _orders.isNotEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: AppText(
                    'All orders loaded',
                    fontSize: 12,
                    color: AppColors.slate400,
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }
}
