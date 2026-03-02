// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_my_review_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewData _$ReviewDataFromJson(Map<String, dynamic> json) => ReviewData(
  reviewId: json['review_id'] as String,
  orderId: json['order_id'] as String,
  ratingOverall: (json['rating_overall'] as num).toInt(),
);

Map<String, dynamic> _$ReviewDataToJson(ReviewData instance) =>
    <String, dynamic>{
      'review_id': instance.reviewId,
      'order_id': instance.orderId,
      'rating_overall': instance.ratingOverall,
    };

GetMyReviewData _$GetMyReviewDataFromJson(Map<String, dynamic> json) =>
    GetMyReviewData(
      review: ReviewData.fromJson(json['review'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GetMyReviewDataToJson(GetMyReviewData instance) =>
    <String, dynamic>{'review': instance.review};
