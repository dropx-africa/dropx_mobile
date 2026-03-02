// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_feed_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomeFeedData _$HomeFeedDataFromJson(Map<String, dynamic> json) => HomeFeedData(
  items: (json['items'] as List<dynamic>)
      .map((e) => FeedItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  nextCursor: json['next_cursor'] as String?,
);

Map<String, dynamic> _$HomeFeedDataToJson(HomeFeedData instance) =>
    <String, dynamic>{
      'items': instance.items.map((e) => e.toJson()).toList(),
      'next_cursor': instance.nextCursor,
    };
