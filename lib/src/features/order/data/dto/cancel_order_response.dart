import 'package:json_annotation/json_annotation.dart';

part 'cancel_order_response.g.dart';

@JsonSerializable(explicitToJson: true)
class CancelOrderResponse {
  final bool ok;
  final CancelOrderData data;

  const CancelOrderResponse({required this.ok, required this.data});

  factory CancelOrderResponse.fromJson(Map<String, dynamic> json) =>
      _$CancelOrderResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CancelOrderResponseToJson(this);
}

@JsonSerializable()
class CancelOrderData {
  @JsonKey(name: 'order_id')
  final String orderId;
  final String state;

  @JsonKey(name: 'wallet_refunded')
  final bool? walletRefunded;

  const CancelOrderData({
    required this.orderId,
    required this.state,
    this.walletRefunded,
  });

  factory CancelOrderData.fromJson(Map<String, dynamic> json) =>
      _$CancelOrderDataFromJson(json);

  Map<String, dynamic> toJson() => _$CancelOrderDataToJson(this);
}
