import 'package:json_annotation/json_annotation.dart';

part 'order_item.g.dart';

int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  if (value is double) return value.toInt();
  return 0;
}

/// A single line item within an order.
@JsonSerializable()
class OrderItem {
  @JsonKey(name: 'order_item_id')
  final String orderItemId;

  @JsonKey(name: 'order_id')
  final String orderId;

  final String name;
  @JsonKey(fromJson: _parseInt)
  final int qty;

  @JsonKey(name: 'unit_price_kobo', fromJson: _parseInt)
  final int unitPriceKobo;

  @JsonKey(name: 'created_at')
  final String createdAt;

  const OrderItem({
    required this.orderItemId,
    required this.orderId,
    required this.name,
    required this.qty,
    required this.unitPriceKobo,
    required this.createdAt,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);

  Map<String, dynamic> toJson() => _$OrderItemToJson(this);
}
