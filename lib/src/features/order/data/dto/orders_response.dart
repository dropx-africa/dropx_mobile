import 'package:json_annotation/json_annotation.dart';
import 'package:dropx_mobile/src/models/order.dart';

part 'orders_response.g.dart';

/// Response DTO for `GET /orders`.
@JsonSerializable()
class OrdersResponse {
  final bool ok;
  final List<Order> orders;

  @JsonKey(name: 'next_cursor')
  final String? nextCursor;

  const OrdersResponse({
    required this.ok,
    required this.orders,
    this.nextCursor,
  });

  factory OrdersResponse.fromJson(Map<String, dynamic> json) =>
      _$OrdersResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OrdersResponseToJson(this);
}
