import 'package:json_annotation/json_annotation.dart';

part 'order.g.dart';

/// Order model representing a completed or in-progress order.
@JsonSerializable()
class Order {
  final String id;
  @JsonKey(name: 'vendor_name')
  final String vendorName;
  @JsonKey(name: 'vendor_logo')
  final String vendorLogo;
  @JsonKey(name: 'items_summary')
  final String itemsSummary;
  final String date;
  final double price;
  final String status;

  const Order({
    required this.id,
    required this.vendorName,
    required this.vendorLogo,
    required this.itemsSummary,
    required this.date,
    required this.price,
    required this.status,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);
}
