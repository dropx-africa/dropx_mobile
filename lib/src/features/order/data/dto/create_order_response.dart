import 'package:json_annotation/json_annotation.dart';

part 'create_order_response.g.dart';

/// Response DTO for `POST /orders`.
///
/// Contains a lightweight order summary (id, state, total).
@JsonSerializable()
class CreateOrderResponse {
  final bool ok;
  final CreateOrderSummary order;

  const CreateOrderResponse({required this.ok, required this.order});

  factory CreateOrderResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateOrderResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CreateOrderResponseToJson(this);
}

/// Lightweight order object returned when a new order is created.
@JsonSerializable()
class CreateOrderSummary {
  @JsonKey(name: 'order_id')
  final String orderId;

  final String state;

  @JsonKey(name: 'total_amount_kobo')
  final String totalAmountKobo;

  const CreateOrderSummary({
    required this.orderId,
    required this.state,
    required this.totalAmountKobo,
  });

  factory CreateOrderSummary.fromJson(Map<String, dynamic> json) =>
      _$CreateOrderSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$CreateOrderSummaryToJson(this);
}
