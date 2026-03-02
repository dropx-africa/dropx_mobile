// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$SyncContactsDtoToJson(SyncContactsDto instance) =>
    <String, dynamic>{'hashed_contacts': instance.hashedContacts};

SyncContactsData _$SyncContactsDataFromJson(Map<String, dynamic> json) =>
    SyncContactsData(
      receivedCount: (json['received_count'] as num).toInt(),
      syncedCount: (json['synced_count'] as num).toInt(),
    );

Map<String, dynamic> _$SyncContactsDataToJson(SyncContactsData instance) =>
    <String, dynamic>{
      'received_count': instance.receivedCount,
      'synced_count': instance.syncedCount,
    };

SocialFeedEvent _$SocialFeedEventFromJson(Map<String, dynamic> json) =>
    SocialFeedEvent(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      meta: json['meta'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$SocialFeedEventToJson(SocialFeedEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'title': instance.title,
      'body': instance.body,
      'created_at': instance.createdAt.toIso8601String(),
      'meta': instance.meta,
    };

SocialFeedData _$SocialFeedDataFromJson(Map<String, dynamic> json) =>
    SocialFeedData(
      events: (json['events'] as List<dynamic>)
          .map((e) => SocialFeedEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['next_cursor'] as String?,
    );

Map<String, dynamic> _$SocialFeedDataToJson(SocialFeedData instance) =>
    <String, dynamic>{
      'events': instance.events,
      'next_cursor': instance.nextCursor,
    };
