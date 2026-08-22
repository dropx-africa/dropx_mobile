import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/constants/app_icons.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/app_loading_widget.dart';
import 'package:dropx_mobile/src/common_widgets/app_error_widget.dart';
import 'package:dropx_mobile/src/common_widgets/app_search_bar.dart';
import 'package:dropx_mobile/src/common_widgets/app_back_button.dart';
import 'package:dropx_mobile/src/common_widgets/app_scaffold.dart';
import 'package:dropx_mobile/src/common_widgets/delivery_zone_notice.dart';
import 'package:dropx_mobile/src/models/menu_item.dart';
import 'package:dropx_mobile/src/models/vendor_category.dart';
import 'package:dropx_mobile/src/features/menu/presentation/widgets/menu_item_card.dart';
import 'package:dropx_mobile/src/features/menu/presentation/widgets/bottom_cart_bar.dart';
import 'package:dropx_mobile/src/features/menu/presentation/widgets/item_add_sheet.dart';
import 'package:dropx_mobile/src/features/cart/providers/cart_provider.dart';
import 'package:dropx_mobile/src/features/auth/presentation/sign_up_to_order_sheet.dart';
import 'package:dropx_mobile/src/features/vendor/providers/vendor_providers.dart';
import 'package:dropx_mobile/src/core/providers/core_providers.dart';
import 'package:dropx_mobile/src/features/group/providers/group_order_providers.dart';
import 'package:dropx_mobile/src/route/page.dart';
import 'package:dropx_mobile/src/utils/app_navigator.dart';

import '../../../core/services/session_service.dart';
import '../../group/presentation/widgets/quick_add_widget.dart';

class VendorMenuScreen extends ConsumerStatefulWidget {
  final String vendorId;
  final VendorCategory? category;
  final String? groupOrderId;
  final String? groupParticipantToken;
  final bool isGroupOrderMode;

  const VendorMenuScreen({
    super.key,
    required this.vendorId,
    this.category,
    this.groupOrderId,
    this.groupParticipantToken,
    this.isGroupOrderMode = false,
  });
  @override
  ConsumerState<VendorMenuScreen> createState() => _VendorMenuScreenState();
}

class _VendorMenuScreenState extends ConsumerState<VendorMenuScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isSearching = false;
  bool _crossZoneChecked = false;

  /// Checks whether this vendor is outside the customer's delivery zone and,
  /// if so, shows a one-off warning modal before they've added anything to
  /// cart — so a higher delivery fee is never a surprise later at checkout.
  /// Best-effort: any failure here is silently ignored since the real,
  /// numbers-backed notice still shows on the cart screen regardless.
  Future<void> _maybeShowCrossZoneNotice(Map<String, dynamic> store) async {
    final vendorZoneId = store['zone_id'] as String?;
    if (vendorZoneId == null) return;

    final session = ref.read(sessionServiceProvider);
    try {
      final resolution = await ref
          .read(locationRepositoryProvider)
          .resolveZone(session.savedLat, session.savedLng);
      if (!mounted) return;
      if (resolution.zoneId != null && resolution.zoneId != vendorZoneId) {
        DeliveryZoneNotice.showPreviewModal(context);
      }
    } catch (_) {
      // Ignore — this is only a preview, not the source of truth.
    }
  }

  List<String> _buildCategories(List<MenuItem> items) {
    final cats = items.map((item) => item.category ?? 'Other').toSet().toList();
    return ['All', ...cats];
  }

  List<MenuItem> _filterItems(List<MenuItem> items) {
    var filtered = items;
    if (_selectedCategory != 'All') {
      filtered = filtered
          .where((item) => (item.category ?? 'Other') == _selectedCategory)
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (item) =>
            item.name.toLowerCase().contains(_searchQuery.toLowerCase()),
      )
          .toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionServiceProvider);
    final isGuest = session.isGuest;

    // Pass category through so retail stores get ?category=shops
    final catalogParams = StoreCatalogParams(
      vendorId: widget.vendorId,
      category: widget.category,
    );
    final catalogAsync = ref.watch(storeCatalogProvider(catalogParams));
    final cartState = ref.watch(cartProvider);

    return Stack(
      children: [
        AppScaffold(
          useSafeArea: false,
          onRefresh: () =>
              ref.refresh(storeCatalogProvider(catalogParams).future),
          slivers: [
            catalogAsync.when(
              loading: () => const SliverFillRemaining(child: AppLoading()),
              error: (error, _) => SliverFillRemaining(
                child: AppErrorWidget(
                  message: error.toString(),
                  onRetry: () =>
                      ref.invalidate(storeCatalogProvider(catalogParams)),
                ),
              ),
              data: (catalog) {
                final store = catalog.store;
                final allItems = catalog.items;
                final categories = _buildCategories(allItems);
                final filteredItems = _filterItems(allItems);

                if (!_crossZoneChecked) {
                  _crossZoneChecked = true;
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => _maybeShowCrossZoneNotice(store),
                  );
                }

                final storeName =
                    store['display_name'] as String? ?? 'Store';
                final storeImage = store['image_url'] as String?;
                final storeTags =
                    (store['tags'] as List?)?.cast<String>() ?? [];
                final storeRating = store['rating'];
                final etaMinutes = store['eta_minutes'] as int?;
                final isOpen = store['is_open'] as bool? ?? true;
                final isAcceptingOrders =
                    store['is_accepting_orders'] as bool? ?? true;
                final closedReason = store['closed_reason'] as String?;
                final opensAt = store['opens_at'] as String?;
                final canOrder = isOpen && isAcceptingOrders;

                return SliverMainAxisGroup(
                  slivers: [
                    // Hero app bar
                    SliverAppBar(
                      pinned: true,
                      expandedHeight: 200,
                      leading: const Padding(
                        padding: EdgeInsets.all(8),
                        child: AppBackButton(),
                      ),
                      actions: [
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: IconButton(
                              icon: Icon(
                                _isSearching ? Icons.close : Icons.search,
                                color: Colors.black,
                              ),
                              onPressed: () => setState(() {
                                _isSearching = !_isSearching;
                                if (!_isSearching) _searchQuery = '';
                              }),
                            ),
                          ),
                        ),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            storeImage != null
                                ? Image.network(
                              storeImage,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Image.asset(
                                AppIcon.vendorBanner,
                                fit: BoxFit.cover,
                              ),
                            )
                                : Image.asset(
                              AppIcon.vendorBanner,
                              fit: BoxFit.cover,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.4),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Store info
                    SliverToBoxAdapter(
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      AppText(
                                        storeName,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      if (storeTags.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        AppSubText(
                                          storeTags.join(' • '),
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isOpen
                                        ? Colors.green.shade50
                                        : Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: isOpen
                                              ? Colors.green
                                              : Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      AppText(
                                        isOpen ? 'Open' : 'Closed',
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isOpen
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 6,
                              children: [
                                if (storeRating != null)
                                  _metaItem(
                                    Icons.star,
                                    '${storeRating is double ? storeRating.toStringAsFixed(1) : storeRating}',
                                    color: AppColors.primaryOrange,
                                  ),
                                if (etaMinutes != null)
                                  _metaItem(
                                      Icons.access_time, '$etaMinutes min'),
                                // Delivery fee and distance are omitted here —
                                // this endpoint doesn't have the customer's
                                // real location, so both would be fabricated
                                // per-vendor placeholder numbers rather than
                                // an actual estimate. The real delivery fee
                                // is shown at checkout (POST /orders/estimate).
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Group order banner ────────────────────────────
                    if (canOrder && !isGuest)
                      SliverToBoxAdapter(
                        child: _GroupOrderBanner(
                          vendorId: widget.vendorId,
                          vendorName: storeName,
                        ),
                      ),

                    // Closed / not-accepting banner
                    if (!canOrder)
                      SliverToBoxAdapter(
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline,
                                  size: 16, color: Colors.red.shade700),
                              const SizedBox(width: 8),
                              Expanded(
                                child: AppText(
                                  _buildClosedMessage(
                                    isOpen: isOpen,
                                    closedReason: closedReason,
                                    opensAt: opensAt,
                                  ),
                                  fontSize: 13,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Sticky category tab bar
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _StickyTabBarDelegate(
                        child: Container(
                          color: Colors.white,
                          padding:
                          const EdgeInsets.symmetric(vertical: 12),
                          child: SizedBox(
                            height: 36,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16),
                              itemCount: categories.length,
                              itemBuilder: (context, index) {
                                final cat = categories[index];
                                final isSelected =
                                    cat == _selectedCategory;
                                final label = cat.isEmpty
                                    ? cat
                                    : '${cat[0].toUpperCase()}${cat.substring(1)}';
                                return Padding(
                                  padding:
                                  const EdgeInsets.only(right: 8),
                                  child: GestureDetector(
                                    onTap: () => setState(
                                            () => _selectedCategory = cat),
                                    child: Container(
                                      padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.primaryOrange
                                            : Colors.white,
                                        borderRadius:
                                        BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.primaryOrange
                                              : Colors.grey.shade300,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          label,
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Inline search bar (toggled)
                    if (_isSearching)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding:
                          const EdgeInsets.fromLTRB(16, 8, 16, 0),
                          child: AppSearchBar(
                            hintText: 'Search items...',
                            onChanged: (val) =>
                                setState(() => _searchQuery = val),
                          ),
                        ),
                      ),

                    // Section title
                    SliverToBoxAdapter(
                      child: Padding(
                        padding:
                        const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: AppText(
                          _selectedCategory == 'All'
                              ? 'All Items'
                              : _selectedCategory,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Items list
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          if (filteredItems.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(32),
                              child: Center(
                                child:
                                AppText('No items in this category'),
                              ),
                            );
                          }
                          final item = filteredItems[index];
                          final quantity =
                              cartState.items[item.id]?.quantity ?? 0;

                          return MenuItemCard(
                            item: item,
                            quantity: quantity,
                              onAdd: canOrder
                                  ? () async {
                                if (isGuest) {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (_) => const SignUpToOrderSheet(),
                                  );
                                  return;
                                }

                                final zoneId = store['zone_id'] as String? ?? '';

                                // Fetch full item detail
                                MenuItem fullItem = item;
                                try {
                                  fullItem = await ref
                                      .read(vendorRepositoryProvider)
                                      .getStoreItem(widget.vendorId, item.id);
                                } catch (_) {
                                  // Fall back to catalog item if fetch fails
                                }

                                if (!context.mounted) return;

                                // Check if we're in group order mode
                                if (widget.isGroupOrderMode && widget.groupOrderId != null && widget.groupParticipantToken != null) {
                                  // Show group-specific add sheet that adds to group cart
                                  _showGroupItemAddSheet(
                                    context,
                                    ref,
                                    item: fullItem,
                                    vendorName: storeName,
                                    zoneId: zoneId,
                                    groupOrderId: widget.groupOrderId!,
                                    participantToken: widget.groupParticipantToken!,
                                  );
                                } else {
                                  // Normal personal cart flow
                                  ItemAddSheet.show(
                                    context,
                                    item: fullItem,
                                    vendorId: widget.vendorId,
                                    vendorName: storeName,
                                    zoneId: zoneId,
                                  );
                                }
                              } : null,
                            onIncrement: canOrder
                                ? () => ref
                                .read(cartProvider.notifier)
                                .increment(item.id)
                                : null,
                            onDecrement: canOrder
                                ? () => ref
                                .read(cartProvider.notifier)
                                .decrement(item.id)
                                : null,
                          );
                        },
                        childCount:
                        filteredItems.isEmpty ? 1 : filteredItems.length,
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                );
              },
            ),
          ],
        ),

        if (cartState.totalItemCount > 0)
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: BottomCartBar(
              itemCount: cartState.totalItemCount,
              totalPrice: cartState.totalPrice,
              isGuest: isGuest,
            ),
          ),
      ],
    );
  }
  void _showGroupItemAddSheet(
      BuildContext context,
      WidgetRef ref, {
        required MenuItem item,
        required String vendorName,
        required String zoneId,
        required String groupOrderId,
        required String participantToken,
      }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GroupItemAddSheet(
        item: item,
        vendorName: vendorName,
        zoneId: zoneId,
        groupOrderId: groupOrderId,
        participantToken: participantToken,
      ),
    );
  }
  String _buildClosedMessage({
    required bool isOpen,
    String? closedReason,
    String? opensAt,
  }) {
    String base;
    if (closedReason?.isNotEmpty == true) {
      base = closedReason!;
    } else if (!isOpen) {
      base = 'This store is currently closed.';
    } else {
      base = 'This store is not accepting orders right now.';
    }
    if (opensAt != null && opensAt.isNotEmpty) {
      base += ' Opens at $opensAt.';
    }
    return base;
  }

  Widget _metaItem(IconData icon, String label, {Color? color}) {
    final c = color ?? Colors.grey.shade700;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: c),
        const SizedBox(width: 4),
        AppText(label, fontSize: 13, color: c),
      ],
    );
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  const _StickyTabBarDelegate({required this.child});

  @override
  double get minExtent => 60;

  @override
  double get maxExtent => 60;

  @override
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent,
      ) {
    return child;
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}

class _GroupOrderBanner extends ConsumerWidget {
  final String vendorId;
  final String vendorName;

  const _GroupOrderBanner({
    required this.vendorId,
    required this.vendorName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionServiceProvider);
    final hasActiveRoom = session.activeGroupOrderId != null &&
        session.activeGroupVendorId == vendorId;

    return GestureDetector(
      onTap: () => hasActiveRoom
          ? _resumeGroupOrder(context, ref, session)
          : _startGroupOrder(context, ref),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: hasActiveRoom ? AppColors.primaryOrange.withValues(alpha: 0.3) : AppColors.darkBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryOrange.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.group_outlined,
                color: AppColors.primaryOrange,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    hasActiveRoom
                        ? 'Group order mode is on.'
                        : 'Ordering with friends?',
                    color: hasActiveRoom ? Colors.grey.shade700 : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  const SizedBox(height: 2),
                  AppText(
                    hasActiveRoom
                        ? 'Tap to return to your shared cart.'
                        : 'Items you add here go into the shared cart',
                    color: hasActiveRoom ? Colors.grey.shade700 : Colors.white,
                    fontSize: 12,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => hasActiveRoom
                  ? _resumeGroupOrder(context, ref, session)
                  : _startGroupOrder(context, ref),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: AppText(
                hasActiveRoom ? 'Open' : 'Start',
                color: AppColors.primaryOrange,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _resumeGroupOrder(
      BuildContext context,
      WidgetRef ref,
      SessionService session,
      ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: AppLoading()),
    );

    try {
      // Try to load the room to verify it's still active
      final groupOrderId = session.activeGroupOrderId!;
      final participantToken = session.activeGroupParticipantToken!;

      final room = await ref
          .read(groupOrderRepositoryProvider)
          .getGroupOrder(groupOrderId, participantToken);

      // Room is gone or finished — clear local session
      if (room.status == 'CHECKED_OUT' || room.status == 'CANCELLED') {
        await session.clearGroupOrderSession();
        if (!context.mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('That group order is no longer active.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      // Room is still open — restore in-memory session and navigate
      ref.read(groupOrderSessionProvider.notifier).state = GroupOrderSession(
        groupOrderId: groupOrderId,
        participantToken: participantToken,
        isHost: session.activeGroupIsHost,
        inviteUrl: session.activeGroupInviteUrl,
        vendorId: session.activeGroupVendorId!,
      );

      if (!context.mounted) return;
      Navigator.pop(context);
      AppNavigator.push(context, AppRoute.groupOrder);
    } catch (e) {
      // Room fetch failed (likely 404 = expired) — clear stale session
      await session.clearGroupOrderSession();
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not find that group order. It may have expired.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _startGroupOrder(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: AppLoading()),
    );

    try {
      final result = await ref
          .read(groupOrderRepositoryProvider)
          .createGroupOrder(vendorId);

      // Persist so host can resume after leaving the app
      await ref.read(sessionServiceProvider).saveGroupOrderSession(
        groupOrderId: result.groupOrderId,
        participantToken: result.participantToken,
        isHost: true,
        inviteUrl: result.inviteUrl,
        vendorId: vendorId,
      );

      ref.read(groupOrderSessionProvider.notifier).state = GroupOrderSession(
        groupOrderId: result.groupOrderId,
        participantToken: result.participantToken,
        isHost: true,
        inviteUrl: result.inviteUrl,
        vendorId: vendorId,
      );

      if (!context.mounted) return;
      Navigator.pop(context);
      AppNavigator.push(context, AppRoute.groupOrder);
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not start group order: $e')),
      );
    }
  }

}