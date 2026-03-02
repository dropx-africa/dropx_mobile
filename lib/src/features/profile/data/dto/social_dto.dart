import 'package:json_annotation/json_annotation.dart';

part 'social_dto.g.dart';

// Sync Contacts DTOs

@JsonSerializable(createFactory: false)
class SyncContactsDto {
  @JsonKey(name: 'hashed_contacts')
  final List<String> hashedContacts;

  const SyncContactsDto({required this.hashedContacts});

  Map<String, dynamic> toJson() => _$SyncContactsDtoToJson(this);
}

@JsonSerializable()
class SyncContactsData {
  @JsonKey(name: 'received_count')
  final int receivedCount;

  @JsonKey(name: 'synced_count')
  final int syncedCount;

  const SyncContactsData({
    required this.receivedCount,
    required this.syncedCount,
  });

  factory SyncContactsData.fromJson(Map<String, dynamic> json) =>
      _$SyncContactsDataFromJson(json);

  Map<String, dynamic> toJson() => _$SyncContactsDataToJson(this);
}

// Social Feed DTOs

@JsonSerializable()
class SocialFeedEvent {
  final String id;
  final String type;
  final String title;
  final String body;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  final Map<String, dynamic>? meta;

  const SocialFeedEvent({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.meta,
  });

  factory SocialFeedEvent.fromJson(Map<String, dynamic> json) =>
      _$SocialFeedEventFromJson(json);

  Map<String, dynamic> toJson() => _$SocialFeedEventToJson(this);
}

@JsonSerializable()
class SocialFeedData {
  final List<SocialFeedEvent> events;

  @JsonKey(name: 'next_cursor')
  final String? nextCursor;

  const SocialFeedData({required this.events, this.nextCursor});

  factory SocialFeedData.fromJson(Map<String, dynamic> json) =>
      _$SocialFeedDataFromJson(json);

  Map<String, dynamic> toJson() => _$SocialFeedDataToJson(this);
}
