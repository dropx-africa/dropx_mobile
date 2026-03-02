import 'package:json_annotation/json_annotation.dart';

part 'submit_review_request.g.dart';

@JsonSerializable(createFactory: false)
class SubmitReviewRequest {
  @JsonKey(name: 'rating_overall')
  final int ratingOverall;

  final String? comment;

  final List<String>? tags;

  @JsonKey(name: 'review_target')
  final String reviewTarget;

  const SubmitReviewRequest({
    required this.ratingOverall,
    this.comment,
    this.tags,
    this.reviewTarget = 'overall',
  });

  Map<String, dynamic> toJson() => _$SubmitReviewRequestToJson(this);
}
