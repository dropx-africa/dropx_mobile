import 'package:json_annotation/json_annotation.dart';

part 'dispute_order_response.g.dart';

@JsonSerializable(explicitToJson: true)
class DisputeOrderResponse {
  final bool ok;
  final DisputeOrderData data;

  const DisputeOrderResponse({required this.ok, required this.data});

  factory DisputeOrderResponse.fromJson(Map<String, dynamic> json) =>
      _$DisputeOrderResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DisputeOrderResponseToJson(this);
}

@JsonSerializable()
class DisputeOrderData {
  @JsonKey(name: 'dispute_id')
  final String disputeId;
  @JsonKey(name: 'order_id')
  final String orderId;
  final String status;

  const DisputeOrderData({
    required this.disputeId,
    required this.orderId,
    required this.status,
  });

  factory DisputeOrderData.fromJson(Map<String, dynamic> json) =>
      _$DisputeOrderDataFromJson(json);

  Map<String, dynamic> toJson() => _$DisputeOrderDataToJson(this);
}
