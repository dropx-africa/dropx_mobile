import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/core/providers/core_providers.dart';
import 'package:dropx_mobile/src/features/profile/data/notification_repository.dart';
import 'package:dropx_mobile/src/features/profile/data/remote_notification_repository.dart';
import 'package:dropx_mobile/src/features/profile/data/dto/notification_dto.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return RemoteNotificationRepository(ref.watch(apiClientProvider));
});

final notificationsFutureProvider = FutureProvider<NotificationFeedData>((ref) {
  return ref.watch(notificationRepositoryProvider).getNotifications();
});
