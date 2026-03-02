import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/features/profile/providers/notification_providers.dart';
import 'package:dropx_mobile/src/features/profile/data/dto/notification_dto.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsFutureProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const AppText(
          "Notifications",
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () async {
              try {
                await ref
                    .read(notificationRepositoryProvider)
                    .readAllNotifications();
                ref.invalidate(notificationsFutureProvider);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to clear notifications'),
                  ),
                );
              }
            },
            child: const AppText(
              "Mark all as read",
              color: AppColors.primaryOrange,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (data) {
          if (data.notifications.isEmpty) {
            return const Center(
              child: AppText("No notifications yet", color: AppColors.slate500),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(notificationsFutureProvider),
            child: ListView.builder(
              itemCount: data.notifications.length,
              itemBuilder: (context, index) {
                final notification = data.notifications[index];
                return _NotificationTile(notification: notification);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AppText(
                "Failed to load notifications",
                color: AppColors.errorRed,
              ),
              TextButton(
                onPressed: () => ref.invalidate(notificationsFutureProvider),
                child: const AppText("Retry"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  final NotificationItem notification;

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUnread = !notification.read;
    return InkWell(
      onTap: () async {
        if (isUnread) {
          try {
            await ref
                .read(notificationRepositoryProvider)
                .readNotification(notification.id);
            ref.invalidate(notificationsFutureProvider);
          } catch (e) {
            // Error silencing for UI
          }
        }
      },
      child: Container(
        color: isUnread
            ? AppColors.primaryOrange.withValues(alpha: 0.05)
            : Colors.transparent,
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUnread
                    ? AppColors.primaryOrange.withValues(alpha: 0.1)
                    : AppColors.slate100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconForType(notification.type),
                color: isUnread ? AppColors.primaryOrange : AppColors.slate500,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    notification.title,
                    fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                    fontSize: 16,
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    notification.body,
                    color: AppColors.slate500,
                    fontSize: 14,
                    height: 1.4,
                  ),
                  const SizedBox(height: 8),
                  AppText(
                    DateFormat.yMMMd().add_jm().format(notification.createdAt),
                    color: AppColors.slate400,
                    fontSize: 12,
                  ),
                ],
              ),
            ),
            if (isUnread)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primaryOrange,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'ORDER_UPDATE':
      case 'ORDER_DELIVERED':
        return Icons.local_shipping_rounded;
      case 'PROMOTION':
        return Icons.local_offer_rounded;
      case 'SYSTEM_ALERT':
        return Icons.warning_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }
}
