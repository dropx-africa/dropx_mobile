import 'package:json_annotation/json_annotation.dart';

part 'get_my_review_response.g.dart';

@JsonSerializable()
class ReviewData {
  @JsonKey(name: 'review_id')
  final String reviewId;

  @JsonKey(name: 'order_id')
  final String orderId;

  @JsonKey(name: 'rating_overall')
  final int ratingOverall;

  const ReviewData({
    required this.reviewId,
    required this.orderId,
    required this.ratingOverall,
  });

  factory ReviewData.fromJson(Map<String, dynamic> json) =>
      _$ReviewDataFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewDataToJson(this);
}

@JsonSerializable()
class GetMyReviewData {
  final ReviewData review;

  const GetMyReviewData({required this.review});

  factory GetMyReviewData.fromJson(Map<String, dynamic> json) =>
      _$GetMyReviewDataFromJson(json);

  Map<String, dynamic> toJson() => _$GetMyReviewDataToJson(this);
}
