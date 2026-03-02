// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationItem _$NotificationItemFromJson(Map<String, dynamic> json) =>
    NotificationItem(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      read: json['read'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      meta: json['meta'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$NotificationItemToJson(NotificationItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'title': instance.title,
      'body': instance.body,
      'read': instance.read,
      'created_at': instance.createdAt.toIso8601String(),
      'meta': instance.meta,
    };

NotificationFeedData _$NotificationFeedDataFromJson(
  Map<String, dynamic> json,
) => NotificationFeedData(
  notifications: (json['notifications'] as List<dynamic>)
      .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  unreadCount: (json['unread_count'] as num).toInt(),
  nextCursor: json['next_cursor'] as String?,
);

Map<String, dynamic> _$NotificationFeedDataToJson(
  NotificationFeedData instance,
) => <String, dynamic>{
  'notifications': instance.notifications,
  'unread_count': instance.unreadCount,
  'next_cursor': instance.nextCursor,
};

ReadAllNotificationsData _$ReadAllNotificationsDataFromJson(
  Map<String, dynamic> json,
) => ReadAllNotificationsData(
  markedCount: (json['marked_count'] as num).toInt(),
  unreadCount: (json['unread_count'] as num).toInt(),
);

Map<String, dynamic> _$ReadAllNotificationsDataToJson(
  ReadAllNotificationsData instance,
) => <String, dynamic>{
  'marked_count': instance.markedCount,
  'unread_count': instance.unreadCount,
};

ReadNotificationData _$ReadNotificationDataFromJson(
  Map<String, dynamic> json,
) => ReadNotificationData(
  id: json['id'] as String,
  read: json['read'] as bool,
  readAt: DateTime.parse(json['read_at'] as String),
  unreadCount: (json['unread_count'] as num).toInt(),
);

Map<String, dynamic> _$ReadNotificationDataToJson(
  ReadNotificationData instance,
) => <String, dynamic>{
  'id': instance.id,
  'read': instance.read,
  'read_at': instance.readAt.toIso8601String(),
  'unread_count': instance.unreadCount,
};
