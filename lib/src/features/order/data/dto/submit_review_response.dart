import 'package:json_annotation/json_annotation.dart';

part 'submit_review_response.g.dart';

@JsonSerializable()
class SubmitReviewData {
  @JsonKey(name: 'review_id')
  final String reviewId;

  @JsonKey(name: 'order_id')
  final String orderId;

  @JsonKey(name: 'created_at')
  final String createdAt;

  const SubmitReviewData({
    required this.reviewId,
    required this.orderId,
    required this.createdAt,
  });

  factory SubmitReviewData.fromJson(Map<String, dynamic> json) =>
      _$SubmitReviewDataFromJson(json);

  Map<String, dynamic> toJson() => _$SubmitReviewDataToJson(this);
}

class SubmitReviewResponse {
  final bool ok;
  final SubmitReviewData data;

  const SubmitReviewResponse({required this.ok, required this.data});
}
