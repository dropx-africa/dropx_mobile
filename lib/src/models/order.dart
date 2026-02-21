import 'package:json_annotation/json_annotation.dart';
import 'package:dropx_mobile/src/models/order_item.dart';

part 'order.g.dart';

dynamic _parseToString(dynamic value) => value?.toString();

/// Order model matching the real API response shape.
@JsonSerializable()
class Order {
  @JsonKey(name: 'order_id')
  final String orderId;

  @JsonKey(name: 'customer_user_id')
  final String? customerUserId;

  @JsonKey(name: 'vendor_id')
  final String? vendorId;

  @JsonKey(name: 'zone_id')
  final String? zoneId;

  final String state;
  final String? currency;

  @JsonKey(name: 'total_amount_kobo', fromJson: _parseToString)
  final String totalAmountKobo;

  @JsonKey(name: 'delivery_address')
  final String? deliveryAddress;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  final List<OrderItem>? items;

  const Order({
    required this.orderId,
    this.customerUserId,
    this.vendorId,
    this.zoneId,
    required this.state,
    this.currency,
    required this.totalAmountKobo,
    this.deliveryAddress,
    this.createdAt,
    this.updatedAt,
    this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

  Map<String, dynamic> toJson() => _$OrderToJson(this);
}
