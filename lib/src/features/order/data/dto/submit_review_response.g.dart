// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submit_review_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubmitReviewData _$SubmitReviewDataFromJson(Map<String, dynamic> json) =>
    SubmitReviewData(
      reviewId: json['review_id'] as String,
      orderId: json['order_id'] as String,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$SubmitReviewDataToJson(SubmitReviewData instance) =>
    <String, dynamic>{
      'review_id': instance.reviewId,
      'order_id': instance.orderId,
      'created_at': instance.createdAt,
    };
