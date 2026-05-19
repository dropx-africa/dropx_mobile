import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/app_loading_widget.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/features/group/data/dto/group_order_models.dart';
import 'package:dropx_mobile/src/features/group/providers/group_order_providers.dart';
import 'package:dropx_mobile/src/route/page.dart';
import 'package:dropx_mobile/src/utils/app_navigator.dart';

import '../../../common_widgets/app_toast.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/services/session_service.dart';
import '../../../utils/currency_utils.dart';
import '../../cart/presentation/cart_screen.dart';
import '../../order/data/dto/generate_payment_link_dto.dart';
import '../../order/data/dto/initialize_payment_dto.dart';
import '../../order/data/dto/place_order_dto.dart';
import '../../order/providers/order_providers.dart';
import '../../wallet/providers/wallet_providers.dart';

class GroupOrderScreen extends ConsumerWidget {
  const GroupOrderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(groupOrderSessionProvider);
    final roomAsync = ref.watch(groupOrderProvider);

    if (session == null) {
      return const Scaffold(
        body: Center(child: AppText('No active group order')),
      );
    }

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          ref.read(groupOrderSessionProvider.notifier).state = null;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const AppText(
            'Group order',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black),
              onPressed: () =>
                  ref.read(groupOrderProvider.notifier).refresh(),
            ),
          ],
        ),
        body: roomAsync.when(
          loading: () => const Center(child: AppLoading()),
          error: (e, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: AppColors.slate200),
                const SizedBox(height: 12),
                AppText(e.toString(), color: AppColors.slate400),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      ref.read(groupOrderProvider.notifier).refresh(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text('Retry',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
          data: (room) {
            if (room == null) {
              return const Center(child: AppText('Room not found'));
            }
            return _RoomBody(
              room: room,
              session: session,
            );
          },
        ),
      ),
    );
  }
}

class _RoomBody extends ConsumerWidget {
  final GroupOrder room;
  final GroupOrderSession session;

  const _RoomBody({required this.room, required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHost = session.isHost;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero status card ──────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.darkBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _StatusBadge(status: room.status),
                          AppText(
                            '${room.participants.length} '
                                '${room.participants.length == 1 ? 'person' : 'people'}',
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      AppText(
                        '${room.vendorName} group order',
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 6),
                      AppText(
                        '${room.vendorName} • '
                            '${room.itemCount} ${room.itemCount == 1 ? 'item' : 'items'} • '
                            '₦${room.total.toInt()}',
                        color: Colors.white60,
                        fontSize: 13,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Invite banner (shown when room is open) ───────────────
                if (room.isOpen && session.inviteUrl != null)
                  _InviteBanner(inviteUrl: session.inviteUrl!),

                const SizedBox(height: 20),

                // ── Participants ──────────────────────────────────────────
                const AppText(
                  'People',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: room.participants.map((p) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: p.isHost
                              ? AppColors.primaryOrange
                              .withValues(alpha: 0.1)
                              : AppColors.slate50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: AppText(
                          p.isHost
                              ? '${p.displayName} • Host'
                              : p.displayName,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: p.isHost
                              ? AppColors.primaryOrange
                              : AppColors.darkBackground,
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Shared cart ───────────────────────────────────────────
                const AppText(
                  'Shared cart',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 12),

                if (room.items.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.slate50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.shopping_basket_outlined,
                            size: 40, color: AppColors.slate200),
                        const SizedBox(height: 12),
                        const AppText(
                          'No one has added items yet.',
                          fontWeight: FontWeight.w600,
                        ),
                        const SizedBox(height: 4),
                        AppText(
                          'Share the invite or add your first line.',
                          color: AppColors.slate400,
                          fontSize: 13,
                        ),
                      ],
                    ),
                  )
                else
                  ..._buildItemsByParticipant(context, ref, room),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),

        // ── Bottom actions ────────────────────────────────────────────────
        _BottomActions(room: room, session: session, isHost: isHost),
      ],
    );
  }

  /// Groups items by participant and renders each group with a header.
  List<Widget> _buildItemsByParticipant(
      BuildContext context,
      WidgetRef ref,
      GroupOrder room,
      ) {
    // Group items by participantId
    final Map<String, List<GroupOrderItem>> grouped = {};
    for (final item in room.items) {
      grouped.putIfAbsent(item.participantId, () => []).add(item);
    }

    return grouped.entries.map((entry) {
      final participantName = entry.value.first.participantDisplayName;
      final items = entry.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AppText(
              participantName,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.slate400,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: items.asMap().entries.map((e) {
                final isLast = e.key == items.length - 1;
                return _GroupItemTile(
                  item: e.value,
                  isLocked: room.isLocked,
                  canRemove: session.isHost ||
                      e.value.participantId == session.participantToken,
                  isLast: isLast,
                  onRemove: room.isLocked
                      ? null
                      : () => ref
                      .read(groupOrderProvider.notifier)
                      .removeItem(e.value.groupOrderItemId),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],
      );
    }).toList();
  }
}

class _GroupItemTile extends StatelessWidget {
  final GroupOrderItem item;
  final bool isLocked;
  final bool canRemove;
  final bool isLast;
  final VoidCallback? onRemove;

  const _GroupItemTile({
    required this.item,
    required this.isLocked,
    required this.canRemove,
    required this.isLast,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      item.name,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    const SizedBox(height: 2),
                    AppText(
                      '${item.quantity}× ₦${item.unitPrice.toInt()}',
                      fontSize: 12,
                      color: AppColors.slate400,
                    ),
                    if (item.note != null && item.note!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      AppText(
                        'Note: ${item.note}',
                        fontSize: 11,
                        color: AppColors.slate400,
                      ),
                    ],
                  ],
                ),
              ),
              AppText(
                '₦${item.totalPrice.toInt()}',
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              if (canRemove && !isLocked) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: onRemove,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.close,
                        size: 16, color: Colors.grey.shade400),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, color: Colors.grey.shade100),
      ],
    );
  }
}

class _InviteBanner extends StatelessWidget {
  final String inviteUrl;

  const _InviteBanner({required this.inviteUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryOrange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.link,
                color: AppColors.primaryOrange, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  'Invite people to add their own items.',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: 2),
                AppText(
                  'The host pays when everyone is ready.',
                  fontSize: 12,
                  color: AppColors.slate400,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: inviteUrl));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Invite link copied!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const AppText(
              'Copy',
              color: AppColors.primaryOrange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case 'LOCKED':
        color = Colors.orange;
        label = 'LOCKED';
        break;
      case 'CHECKED_OUT':
      case 'CANCELLED':
        color = Colors.red;
        label = status.replaceAll('_', ' ');
        break;
      default:
        color = AppColors.secondaryGreen;
        label = 'OPEN';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: AppText(
        label,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}

class _BottomActions extends ConsumerWidget {
  final GroupOrder room;
  final GroupOrderSession session;
  final bool isHost;

  const _BottomActions({
    required this.room,
    required this.session,
    required this.isHost,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Add items button — available to everyone while room is open
          if (room.isOpen)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Navigate back to the vendor menu so the user can add items.
                  // The vendor menu screen adds items to the group cart via the
                  // group order notifier rather than the personal cart.
                  AppNavigator.push(
                    context,
                    AppRoute.vendorMenu,
                    arguments: {
                      'vendorId': room.vendorId,
                      'isGroupOrderMode': true,
                      'groupOrderId': session.groupOrderId,
                      'groupParticipantToken': session.participantToken,
                    },
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryOrange),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                icon: const Icon(Icons.add, color: AppColors.primaryOrange),
                label: AppText(
                  room.vendorName.isNotEmpty
                      ? 'Add from ${room.vendorName.length > 20 ? '${room.vendorName.substring(0, 18)}…' : room.vendorName}'
                      : 'Add more items',
                  color: AppColors.primaryOrange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          if (room.isOpen) const SizedBox(height: 10),

          // Lock and checkout — host only
          if (isHost)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: room.items.isEmpty
                    ? null
                    : () => _onLockOrCheckout(context, ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: room.items.isEmpty
                      ? AppColors.slate200
                      : AppColors.darkBackground,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                icon: Icon(
                  room.isLocked ? Icons.shopping_bag_outlined : Icons.lock,
                  color: room.items.isEmpty
                      ? AppColors.slate400
                      : Colors.white,
                  size: 18,
                ),
                label: AppText(
                  room.isLocked
                      ? 'Review and checkout'
                      : 'Lock group and review checkout',
                  color: room.items.isEmpty ? AppColors.slate400 : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          // Non-host waiting state when locked
          if (!isHost && room.isLocked)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.slate50,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline,
                      size: 16, color: AppColors.slate400),
                  SizedBox(width: 8),
                  AppText(
                    'Waiting for host to checkout…',
                    color: AppColors.slate400,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _onLockOrCheckout(
      BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(groupOrderProvider.notifier);

    if (room.isOpen) {
      // Lock first
      try {
        await notifier.lock();
      } catch (e) {

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to lock: $e')),
          );
        }
        return;
      }
    }

    // Estimate — show unavailable items if any
    if (!context.mounted) return;
    try {
      final estimate = await notifier.estimate();
      if (!context.mounted) return;

      if (estimate.unavailableItems.isNotEmpty) {
        await _showUnavailableItemsDialog(context, estimate.unavailableItems);
        if (!context.mounted) return;
      }

      // Confirm total and checkout
      await _showCheckoutConfirm(context, ref, estimate);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to estimate: $e')),
        );
      }
    }
  }

  Future<void> _showUnavailableItemsDialog(
      BuildContext context,
      List<Map<String, dynamic>> items,
      ) {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const AppText(
          'Some items are unavailable',
          fontWeight: FontWeight.bold,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              'The following items will be removed from the order:',
              fontSize: 13,
              color: AppColors.slate400,
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(Icons.remove_circle_outline,
                      size: 14, color: Colors.red),
                  const SizedBox(width: 6),
                  Expanded(
                    child: AppText(
                      item['name'] as String? ?? 'Unknown item',
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const AppText('OK', color: AppColors.primaryOrange),
          ),
        ],
      ),
    );
  }

  Future<void> _showCheckoutConfirm(
      BuildContext context,
      WidgetRef ref,
      GroupOrderEstimate estimate,
      ) async {
    final sessionService = ref.read(sessionServiceProvider);
    final isAuthenticated = sessionService.isLoggedIn;

    // Show payment method selection first
    final paymentMethod = await _showPaymentMethodSheet(context, ref, estimate.total);
    if (paymentMethod == null || !context.mounted) return;

    // If wallet is selected, check balance first
    if (paymentMethod == 'WALLET') {
      final canProceed = await _checkWalletBalance(context, ref, estimate.total);
      if (!canProceed || !context.mounted) return;
    }

    // Show the order summary with payment method
    final confirmed = await _showOrderSummarySheet(context, ref, estimate);
    if (confirmed != true || !context.mounted) return;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Create the order
      final result = await ref.read(groupOrderProvider.notifier).checkout();

      if (!context.mounted) return;
      Navigator.pop(context); // Close loading dialog

      // Route based on payment method (matching regular cart flow)
      if (paymentMethod == 'WALLET') {
        await _handleWalletPayment(context, ref, result);
      } else if (paymentMethod == 'PAYSTACK') {
        await _handlePaystackPayment(context, ref, result);
      } else if (paymentMethod == 'GENERATE_LINK') {
        await _handlePaymentLink(context, ref, result);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog if error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Checkout failed: $e')),
        );
      }
    }
  }

  Future<bool> _checkWalletBalance(
      BuildContext context,
      WidgetRef ref,
      double totalAmount
      ) async {
    try {
      // Get wallet balance
      final walletBalance = await ref.read(walletBalanceProvider.future);
      final balanceKobo = int.tryParse(walletBalance.availableBalanceKobo) ?? 0;
      final balanceNaira = CurrencyUtils.koboToNaira(balanceKobo);

      print('💰 Wallet balance: ₦$balanceNaira');
      print('💰 Order total: ₦$totalAmount');

      if (balanceNaira < totalAmount) {
        // Insufficient balance - show top-up dialog
        final shouldTopup = await _showInsufficientBalanceDialog(context, totalAmount, balanceNaira);
        if (shouldTopup && context.mounted) {
          await _showTopupBottomSheet(context, ref, totalAmount, balanceNaira);
          return false; // Don't proceed with checkout yet - top-up flow will handle it
        }
        return false;
      }

      return true;
    } catch (e) {
      print('❌ Error checking wallet balance: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to check wallet balance')),
        );
      }
      return false;
    }
  }

  Future<bool> _showInsufficientBalanceDialog(
      BuildContext context,
      double totalAmount,
      double currentBalance
      ) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const AppText(
          'Insufficient Wallet Balance',
          fontWeight: FontWeight.bold,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              'Your wallet balance is ₦${currentBalance.toInt()}',
              fontSize: 14,
            ),
            const SizedBox(height: 8),
            AppText(
              'Order total is ₦${totalAmount.toInt()}',
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 8),
            AppText(
              'You need additional ₦${(totalAmount - currentBalance).toInt()}',
              fontSize: 14,
              color: AppColors.primaryOrange,
            ),
            const SizedBox(height: 16),
            const AppText(
              'Would you like to top up your wallet?',
              fontSize: 14,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const AppText('Cancel', color: AppColors.slate400),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
            ),
            child: const AppText('Top Up', color: Colors.white),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _showTopupBottomSheet(
      BuildContext context,
      WidgetRef ref,
      double totalAmount,
      double currentBalance,
      ) async {
    final success = await AppNavigator.push<bool>(
      context,
      AppRoute.walletTopup,
    );

    if (!context.mounted) return;

    if (success == true) {
      ref.invalidate(walletBalanceProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wallet topped up successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
      // Re-run estimate and retry checkout
      try {
        final newEstimate = await ref.read(groupOrderProvider.notifier).estimate();
        if (context.mounted) {
          _showCheckoutConfirm(context, ref, newEstimate);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to refresh estimate: $e')),
          );
        }
      }
    }
  }

  Future<void> _handleWalletPayment(
      BuildContext context,
      WidgetRef ref,
      GroupOrderCheckoutResponse result,
      ) async {
    try {
      final orderRepo = ref.read(orderRepositoryProvider);

      // Place the order with wallet payment
      await orderRepo.placeOrder(
        result.orderId,
        PlaceOrderDto(paymentMethod: 'WALLET'),
      );

      if (!context.mounted) return;

      // Clear group order session
      await ref.read(sessionServiceProvider).clearGroupOrderSession();
      ref.read(groupOrderSessionProvider.notifier).state = null;

      // Navigate to order success screen (same as regular cart)
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoute.orderSuccess,
            (route) => false,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Wallet payment failed: $e')),
        );
      }
    }
  }

  Future<void> _handlePaystackPayment(
      BuildContext context,
      WidgetRef ref,
      GroupOrderCheckoutResponse result,
      ) async {
    try {
      final orderRepo = ref.read(orderRepositoryProvider);

      // Place the order first (creates DRAFT order)
      await orderRepo.placeOrder(
        result.orderId,
        PlaceOrderDto(paymentMethod: 'PAYSTACK'),
      );

      // Initialize Paystack payment
      final paymentResponse = await orderRepo.initializePayment(
        InitializePaymentDto(orderId: result.orderId),
      );

      if (!context.mounted) return;

      // Clear group order session
      await ref.read(sessionServiceProvider).clearGroupOrderSession();
      ref.read(groupOrderSessionProvider.notifier).state = null;

      // Navigate to Paystack checkout screen (same as regular cart)
      AppNavigator.push(
        context,
        AppRoute.paystackCheckout,
        arguments: {
          'authorizationUrl': paymentResponse.authorizationUrl,
          'reference': paymentResponse.reference,
          'orderId': result.orderId,
        },
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment initialization failed: $e')),
        );
      }
    }
  }

  Future<void> _handlePaymentLink(
      BuildContext context,
      WidgetRef ref,
      GroupOrderCheckoutResponse result,
      ) async {
    try {
      final orderRepo = ref.read(orderRepositoryProvider);

      // Place the order first
      await orderRepo.placeOrder(
        result.orderId,
        PlaceOrderDto(paymentMethod: 'GENERATE_LINK'),
      );

      // Generate payment link
      final linkResponse = await orderRepo.generatePaymentLink(
        result.orderId,
        GeneratePaymentLinkDto(ttlMinutes: 30),
      );

      if (!context.mounted) return;

      final shareableLink = 'https://dropxwebapp.vercel.app/pay-link/${linkResponse.token}';

      // Clear group order session
      await ref.read(sessionServiceProvider).clearGroupOrderSession();
      ref.read(groupOrderSessionProvider.notifier).state = null;

      // Show payment link dialog (same as regular cart)
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const AppText(
            'Payment Link Generated',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppText(
                'Share this link with your friend to complete the payment:',
                fontSize: 14,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: AppText(
                        shareableLink,
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 20),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: shareableLink));
                        AppToast.showSuccess(context, 'Link copied to clipboard!');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to dashboard after generating link (same as regular cart)
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoute.dashboard,
                      (route) => false,
                  arguments: {'initialTab': 2},
                );
              },
              child: const AppText(
                'View Order',
                color: AppColors.primaryOrange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate payment link: $e')),
        );
      }
    }
  }

  Future<String?> _showPaymentMethodSheet(BuildContext context, WidgetRef ref, double totalAmount) async {
    final sessionService = ref.read(sessionServiceProvider);

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _GroupPaymentBottomSheet(
        totalAmount: totalAmount,
        isAuthenticated: sessionService.isLoggedIn,
      ),
    );
  }

  Future<bool?> _showOrderSummarySheet(
      BuildContext context,
      WidgetRef ref,
      GroupOrderEstimate estimate
      ) async {
    final sessionService = ref.read(sessionServiceProvider);

    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return _CheckoutSheetContent(
              estimate: estimate,
              sessionService: sessionService,
              onLocationChange: () async {
                // Location picker logic...
                return null;
              },
              onConfirm: () {
                Navigator.pop(modalContext, true);
              },
            );
          },
        );
      },
    );
  }
}
class _GroupPaymentBottomSheet extends StatefulWidget {
  final double totalAmount;
  final bool isAuthenticated;

  const _GroupPaymentBottomSheet({
    required this.totalAmount,
    required this.isAuthenticated,
  });

  @override
  State<_GroupPaymentBottomSheet> createState() => _GroupPaymentBottomSheetState();
}

class _GroupPaymentBottomSheetState extends State<_GroupPaymentBottomSheet> {
  String _selectedPaymentMethod = 'PAYSTACK';

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, bottomPad + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const AppText(
            'Select Payment Method',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 4),
          AppText(
            'How would you like to pay for this group order?',
            fontSize: 13,
            color: Colors.grey.shade500,
          ),
          const SizedBox(height: 20),
          _buildPaymentOption(
            value: 'PAYSTACK',
            title: 'Card / Bank Transfer',
            subtitle: 'Pay securely via Paystack',
            icon: Icons.credit_card_rounded,
          ),
          if (widget.isAuthenticated) ...[
            const SizedBox(height: 10),
            _buildPaymentOption(
              value: 'WALLET',
              title: 'Wallet',
              subtitle: 'Use your DropX wallet balance',
              icon: Icons.account_balance_wallet_rounded,
            ),
          ],
          const SizedBox(height: 10),
          _buildPaymentOption(
            value: 'GENERATE_LINK',
            title: 'Payment Link',
            subtitle: 'Share a link for someone else to pay',
            icon: Icons.link_rounded,
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, _selectedPaymentMethod),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: AppText(
                'Continue to Review (₦${widget.totalAmount.toInt()})',
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedPaymentMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryOrange.withValues(alpha: 0.07)
              : Colors.grey.shade50,
          border: Border.all(
            color: isSelected ? AppColors.primaryOrange : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryOrange.withValues(alpha: 0.12)
                    : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: isSelected ? AppColors.primaryOrange : Colors.grey.shade600),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(title, fontWeight: FontWeight.bold, fontSize: 14, color: isSelected ? AppColors.primaryOrange : Colors.black87),
                  const SizedBox(height: 2),
                  AppText(subtitle, fontSize: 12, color: Colors.grey.shade500),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppColors.primaryOrange, size: 22),
          ],
        ),
      ),
    );
  }
}
class _CheckoutSheetContent extends StatefulWidget {
  final GroupOrderEstimate estimate;
  final SessionService sessionService;
  final Future<GroupOrderEstimate?> Function() onLocationChange;
  final VoidCallback onConfirm;

  const _CheckoutSheetContent({
    required this.estimate,
    required this.sessionService,
    required this.onLocationChange,
    required this.onConfirm,
  });

  @override
  State<_CheckoutSheetContent> createState() => _CheckoutSheetContentState();
}

class _CheckoutSheetContentState extends State<_CheckoutSheetContent> {
  GroupOrderEstimate? _currentEstimate;
  bool _isUpdatingLocation = false;

  @override
  void initState() {
    super.initState();
    _currentEstimate = widget.estimate;
  }

  @override
  Widget build(BuildContext context) {
    if (_currentEstimate == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Row(
                  children: [
                    Expanded(
                      child: AppText(
                        'Order Summary',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                AppText(
                  'Review your group order before checkout',
                  fontSize: 14,
                  color: AppColors.slate400,
                ),
                const SizedBox(height: 24),

                // Items section
                if (_currentEstimate!.pricedItems.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.slate50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: AppText(
                            'Items',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ..._currentEstimate!.pricedItems.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Center(
                                  child: AppText(
                                    '${item.quantity}',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText(
                                      item.name,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                    if (item.participantDisplayName != null)
                                      AppText(
                                        'Added by ${item.participantDisplayName}',
                                        fontSize: 11,
                                        color: AppColors.slate400,
                                      ),
                                  ],
                                ),
                              ),
                              AppText(
                                '₦${item.unitPrice.toInt()}',
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ],
                          ),
                        )),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AppText(
                                'Item total',
                                fontWeight: FontWeight.w600,
                              ),
                              AppText(
                                '₦${_currentEstimate!.subtotal.toInt()}',
                                fontWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // Price breakdown
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      _SummaryRow(
                        label: 'Subtotal',
                        value: '₦${_currentEstimate!.subtotal.toInt()}',
                      ),
                      const Divider(height: 1),
                      _SummaryRow(
                        label: 'Delivery fee',
                        value: '₦${_currentEstimate!.deliveryFee.toInt()}',
                        subtitle: _currentEstimate!.distanceKm != null
                            ? '${_currentEstimate!.distanceKm!.toStringAsFixed(1)} km away'
                            : null,
                      ),
                      if (_currentEstimate!.serviceFee > 0) ...[
                        const Divider(height: 1),
                        _SummaryRow(
                          label: 'Service fee',
                          value: '₦${_currentEstimate!.serviceFee.toInt()}',
                        ),
                      ],
                      const Divider(height: 1),
                      Container(
                        color: AppColors.primaryOrange.withValues(alpha: 0.05),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _SummaryRow(
                              label: 'Total',
                              value: '₦${_currentEstimate!.total.toInt()}',
                              bold: true,
                              largeText: true,
                            ),
                            if (_currentEstimate!.etaMinutes != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.access_time,
                                        size: 14,
                                        color: AppColors.primaryOrange),
                                    const SizedBox(width: 4),
                                    AppText(
                                      'Est. delivery: ${_currentEstimate!.etaMinutes} minutes',
                                      fontSize: 12,
                                      color: AppColors.primaryOrange,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Tappable delivery address card
                GestureDetector(
                  onTap: _isUpdatingLocation ? null : () async {
                    setState(() => _isUpdatingLocation = true);

                    // Show loading indicator on the address card
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Opening location picker...'),
                        duration: Duration(milliseconds: 500),
                      ),
                    );

                    final newEstimate = await widget.onLocationChange();

                    if (newEstimate != null && mounted) {
                      setState(() {
                        _currentEstimate = newEstimate;
                        _isUpdatingLocation = false;
                      });
                    } else {
                      setState(() => _isUpdatingLocation = false);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.slate50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on,
                            color: AppColors.primaryOrange,
                            size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AppText(
                                'Delivery address',
                                fontSize: 12,
                                color: AppColors.slate400,
                              ),
                              if (_isUpdatingLocation)
                                const Row(
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    AppText(
                                      'Updating location...',
                                      fontSize: 13,
                                    ),
                                  ],
                                )
                              else
                                AppText(
                                  widget.sessionService.savedAddress,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                        const AppText(
                          'Change',
                          color: AppColors.primaryOrange,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Checkout button
                if (_currentEstimate!.canCheckout)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: widget.onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      child: const AppText(
                        'Confirm and pay',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red),
                        SizedBox(width: 8),
                        Expanded(
                          child: AppText(
                            'Cannot checkout at this time. Please try again.',
                            color: Colors.red,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final bool largeText;
  final String? subtitle;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.largeText = false,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                label,
                fontSize: largeText ? 18 : (bold ? 15 : 14),
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                color: bold ? AppColors.darkBackground : AppColors.slate400,
              ),
              AppText(
                value,
                fontSize: largeText ? 18 : (bold ? 16 : 14),
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                color: bold ? AppColors.primaryOrange : AppColors.darkBackground,
              ),
            ],
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  AppText(
                    subtitle!,
                    fontSize: 11,
                    color: AppColors.slate400,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}