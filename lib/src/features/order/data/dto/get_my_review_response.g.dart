// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_my_review_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewData _$ReviewDataFromJson(Map<String, dynamic> json) => ReviewData(
  reviewId: json['review_id'] as String,
  orderId: json['order_id'] as String,
  ratingOverall: (json['rating_overall'] as num).toInt(),
  comment: json['comment'] as String?,
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
  reviewTarget: json['review_target'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$ReviewDataToJson(ReviewData instance) =>
    <String, dynamic>{
      'review_id': instance.reviewId,
      'order_id': instance.orderId,
      'rating_overall': instance.ratingOverall,
      if (instance.comment != null) 'comment': instance.comment,
      if (instance.tags != null) 'tags': instance.tags,
      if (instance.reviewTarget != null) 'review_target': instance.reviewTarget,
      if (instance.createdAt != null)
        'created_at': instance.createdAt!.toIso8601String(),
    };

GetMyReviewData _$GetMyReviewDataFromJson(Map<String, dynamic> json) =>
    GetMyReviewData(
      review: ReviewData.fromJson(json['review'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GetMyReviewDataToJson(GetMyReviewData instance) =>
    <String, dynamic>{'review': instance.review};
