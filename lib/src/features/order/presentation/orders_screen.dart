import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/app_scaffold.dart';
import 'package:dropx_mobile/src/common_widgets/app_appbar.dart';
import 'package:dropx_mobile/src/common_widgets/app_toast.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/utils/app_navigator.dart';
import 'package:dropx_mobile/src/route/page.dart';
import 'package:dropx_mobile/src/features/cart/providers/cart_provider.dart';
import 'package:dropx_mobile/src/features/order/providers/order_providers.dart';
import 'package:dropx_mobile/src/features/order/presentation/widgets/order_history_item.dart';
import 'package:dropx_mobile/src/features/order/data/dto/reorder_preview_response.dart';
import 'package:dropx_mobile/src/models/order.dart';
import 'package:dropx_mobile/src/core/utils/formatters.dart';
import 'package:dropx_mobile/src/utils/currency_utils.dart';

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
  bool _isReordering = false;
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

  Future<void> _confirmReorder(Order order) async {
    setState(() => _isReordering = true);
    ReorderPreviewResponse preview;
    try {
      final repo = ref.read(orderRepositoryProvider);
      preview = await repo.getReorderPreview(order.orderId);
    } catch (e) {
      if (mounted) AppToast.showError(context, 'Failed to load reorder details: $e');
      return;
    } finally {
      if (mounted) setState(() => _isReordering = false);
    }
    if (!mounted) return;

    if (!preview.canReorder) {
      final reason = preview.blockingReasons.isNotEmpty
          ? preview.blockingReasons.join(', ')
          : 'This vendor is not accepting orders right now.';
      AppToast.showError(context, 'Cannot reorder: $reason');
      return;
    }
    if (preview.availableItems.isEmpty) {
      AppToast.showError(
        context,
        'None of the items in this order are available anymore.',
      );
      return;
    }

    final confirmed = await _showReorderPreviewSheet(preview);
    if (confirmed != true || !mounted) return;

    ref.read(cartProvider.notifier).reorderFromPreview(preview);
    AppNavigator.push(context, AppRoute.cart);
  }

  Future<bool?> _showReorderPreviewSheet(ReorderPreviewResponse preview) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: AppText(
                  'Reorder from ${preview.vendor.displayName}',
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    const SizedBox(height: 8),
                    ...preview.availableItems.map(_reorderAvailableTile),
                    if (preview.unavailableItems.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      AppText(
                        'No longer available',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(height: 8),
                      ...preview.unavailableItems.map(_reorderUnavailableTile),
                    ],
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: AppText(
                      'Add ${preview.availableItems.length} '
                      '${preview.availableItems.length == 1 ? 'item' : 'items'} to cart',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _reorderAvailableTile(ReorderAvailableItem item) {
    final name = item.currentName ?? item.previousName ?? 'Item';
    final currentNaira = CurrencyUtils.koboToNaira(item.currentUnitPriceKobo);
    final previousNaira = CurrencyUtils.koboToNaira(item.previousUnitPriceKobo);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(name, fontWeight: FontWeight.w600, fontSize: 14),
                const SizedBox(height: 2),
                AppText('Qty ${item.qty}', fontSize: 12, color: Colors.grey.shade600),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppText(
                Formatters.formatNaira(currentNaira),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              if (item.priceChanged)
                AppText(
                  Formatters.formatNaira(previousNaira),
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  decoration: TextDecoration.lineThrough,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _reorderUnavailableTile(ReorderUnavailableItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(Icons.remove_circle_outline, size: 16, color: Colors.grey.shade400),
          const SizedBox(width: 8),
          Expanded(
            child: AppText(
              item.previousName ?? 'Item',
              fontSize: 13,
              color: Colors.grey.shade500,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          AppText('Qty ${item.qty}', fontSize: 12, color: Colors.grey.shade400),
        ],
      ),
    );
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
        title: 'Orders',
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
        if (_isReordering)
          const SliverToBoxAdapter(
            child: LinearProgressIndicator(
              color: AppColors.primaryOrange,
              backgroundColor: Colors.transparent,
            ),
          ),
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
                      _confirmReorder(order);
                    } else {
                      AppToast.showError(
                        context,
                        'Cannot reorder: No items found in this order.',
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
