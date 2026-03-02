import 'package:dropx_mobile/src/features/profile/data/dto/notification_dto.dart';

abstract class NotificationRepository {
  Future<NotificationFeedData> getNotifications();
  Future<ReadAllNotificationsData> readAllNotifications();
  Future<ReadNotificationData> readNotification(String id);
}
