import 'package:json_annotation/json_annotation.dart';

part 'notification_dto.g.dart';

@JsonSerializable()
class NotificationItem {
  final String id;
  final String type;
  final String title;
  final String body;
  final bool read;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  final Map<String, dynamic>? meta;

  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.read,
    required this.createdAt,
    this.meta,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      _$NotificationItemFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationItemToJson(this);
}

@JsonSerializable()
class NotificationFeedData {
  final List<NotificationItem> notifications;

  @JsonKey(name: 'unread_count')
  final int unreadCount;

  @JsonKey(name: 'next_cursor')
  final String? nextCursor;

  const NotificationFeedData({
    required this.notifications,
    required this.unreadCount,
    this.nextCursor,
  });

  factory NotificationFeedData.fromJson(Map<String, dynamic> json) =>
      _$NotificationFeedDataFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationFeedDataToJson(this);
}

@JsonSerializable()
class ReadAllNotificationsData {
  @JsonKey(name: 'marked_count')
  final int markedCount;

  @JsonKey(name: 'unread_count')
  final int unreadCount;

  const ReadAllNotificationsData({
    required this.markedCount,
    required this.unreadCount,
  });

  factory ReadAllNotificationsData.fromJson(Map<String, dynamic> json) =>
      _$ReadAllNotificationsDataFromJson(json);

  Map<String, dynamic> toJson() => _$ReadAllNotificationsDataToJson(this);
}

@JsonSerializable()
class ReadNotificationData {
  final String id;
  final bool read;

  @JsonKey(name: 'read_at')
  final DateTime readAt;

  @JsonKey(name: 'unread_count')
  final int unreadCount;

  const ReadNotificationData({
    required this.id,
    required this.read,
    required this.readAt,
    required this.unreadCount,
  });

  factory ReadNotificationData.fromJson(Map<String, dynamic> json) =>
      _$ReadNotificationDataFromJson(json);

  Map<String, dynamic> toJson() => _$ReadNotificationDataToJson(this);
}
