import 'package:json_annotation/json_annotation.dart';
import 'package:dropx_mobile/src/features/home/data/feed_item.dart';

part 'home_feed_response.g.dart';

@JsonSerializable(explicitToJson: true)
class HomeFeedData {
  final List<FeedItem> items;

  @JsonKey(name: 'next_cursor')
  final String? nextCursor;

  const HomeFeedData({required this.items, this.nextCursor});

  factory HomeFeedData.fromJson(Map<String, dynamic> json) =>
      _$HomeFeedDataFromJson(json);

  Map<String, dynamic> toJson() => _$HomeFeedDataToJson(this);
}
