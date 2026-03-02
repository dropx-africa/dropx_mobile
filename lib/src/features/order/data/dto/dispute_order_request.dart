import 'package:json_annotation/json_annotation.dart';

part 'dispute_order_request.g.dart';

@JsonSerializable(explicitToJson: true)
class DisputeOrderRequest {
  @JsonKey(name: 'reason_code')
  final String reasonCode;
  final String details;
  @JsonKey(name: 'evidence_urls')
  final List<String>? evidenceUrls;

  const DisputeOrderRequest({
    required this.reasonCode,
    required this.details,
    this.evidenceUrls,
  });

  factory DisputeOrderRequest.fromJson(Map<String, dynamic> json) =>
      _$DisputeOrderRequestFromJson(json);

  Map<String, dynamic> toJson() => _$DisputeOrderRequestToJson(this);
}
