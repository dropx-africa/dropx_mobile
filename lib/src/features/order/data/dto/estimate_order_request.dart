import 'package:json_annotation/json_annotation.dart';

part 'estimate_order_request.g.dart';

@JsonSerializable(explicitToJson: true)
class EstimateOrderRequest {
  @JsonKey(name: 'zone_id')
  final String zoneId;

  @JsonKey(name: 'vendor_id')
  final String vendorId;

  final List<EstimateOrderItem> items;

  @JsonKey(name: 'delivery_address_id')
  final String? deliveryAddressId;

  @JsonKey(name: 'delivery_lat')
  final double deliveryLat;

  @JsonKey(name: 'delivery_lng')
  final double deliveryLng;

  @JsonKey(name: 'service_tier')
  final String serviceTier;

  const EstimateOrderRequest({
    required this.zoneId,
    required this.vendorId,
    required this.items,
    this.deliveryAddressId,
    required this.deliveryLat,
    required this.deliveryLng,
    required this.serviceTier,
  });

  factory EstimateOrderRequest.fromJson(Map<String, dynamic> json) =>
      _$EstimateOrderRequestFromJson(json);

  Map<String, dynamic> toJson() => _$EstimateOrderRequestToJson(this);
}

@JsonSerializable()
class EstimateOrderItem {
  @JsonKey(name: 'item_id')
  final String itemId;

  final String name;
  final int qty;

  @JsonKey(name: 'unit_price_kobo')
  final int unitPriceKobo;

  const EstimateOrderItem({
    required this.itemId,
    required this.name,
    required this.qty,
    required this.unitPriceKobo,
  });

  factory EstimateOrderItem.fromJson(Map<String, dynamic> json) =>
      _$EstimateOrderItemFromJson(json);

  Map<String, dynamic> toJson() => _$EstimateOrderItemToJson(this);
}
