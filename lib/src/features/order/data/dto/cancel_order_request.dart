import 'package:json_annotation/json_annotation.dart';

part 'cancel_order_request.g.dart';

@JsonSerializable(explicitToJson: true)
class CancelOrderRequest {
  @JsonKey(name: 'reason_code')
  final String reasonCode;
  final String note;

  const CancelOrderRequest({required this.reasonCode, required this.note});

  factory CancelOrderRequest.fromJson(Map<String, dynamic> json) =>
      _$CancelOrderRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CancelOrderRequestToJson(this);
}
