import 'package:dropx_mobile/src/core/network/api_client.dart';
import 'package:dropx_mobile/src/core/network/api_endpoints.dart';
import 'package:dropx_mobile/src/features/profile/data/notification_repository.dart';
import 'package:dropx_mobile/src/features/profile/data/dto/notification_dto.dart';

class RemoteNotificationRepository implements NotificationRepository {
  final ApiClient _apiClient;

  RemoteNotificationRepository(this._apiClient);

  @override
  Future<NotificationFeedData> getNotifications() async {
    final response = await _apiClient.get<NotificationFeedData>(
      ApiEndpoints.notifications,
      headers: ApiClient.traceHeaders(),
      fromJson: (json) =>
          NotificationFeedData.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  @override
  Future<ReadAllNotificationsData> readAllNotifications() async {
    final response = await _apiClient.patch<ReadAllNotificationsData>(
      ApiEndpoints.notificationsReadAll,
      headers: ApiClient.traceHeaders(),
      fromJson: (json) =>
          ReadAllNotificationsData.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  @override
  Future<ReadNotificationData> readNotification(String id) async {
    final response = await _apiClient.patch<ReadNotificationData>(
      ApiEndpoints.notificationRead(id),
      headers: ApiClient.traceHeaders(),
      fromJson: (json) =>
          ReadNotificationData.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }
}
