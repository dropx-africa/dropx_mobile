import 'package:json_annotation/json_annotation.dart';
import 'package:dropx_mobile/src/features/order/data/dto/create_order_item_dto.dart';

/// Request payload for `POST /orders`.
class CreateOrderDto {
  @JsonKey(name: 'vendor_id')
  final String vendorId;

  @JsonKey(name: 'zone_id')
  final String zoneId;

  @JsonKey(name: 'delivery_address')
  final String deliveryAddress;

  /// Must match the address id/lat/lng used to generate [quoteId] via
  /// POST /orders/estimate — the backend rejects a mismatch (different or
  /// missing delivery endpoint) with 409 QUOTE_CONTEXT_MISMATCH.
  @JsonKey(name: 'delivery_address_id')
  final String? deliveryAddressId;

  @JsonKey(name: 'delivery_lat')
  final double? deliveryLat;

  @JsonKey(name: 'delivery_lng')
  final double? deliveryLng;

  final List<CreateOrderItemDto> items;

  /// The quote_id from POST /orders/estimate — binds this draft to the
  /// reviewed quote. Required while the quote is unexpired; deployments in
  /// quote ENFORCE mode reject drafts with no quote_id at all.
  @JsonKey(name: 'quote_id')
  final String? quoteId;

  const CreateOrderDto({
    required this.vendorId,
    required this.zoneId,
    required this.deliveryAddress,
    this.deliveryAddressId,
    this.deliveryLat,
    this.deliveryLng,
    required this.items,
    this.quoteId,
  });

  Map<String, dynamic> toJson() => {
    'vendor_id': vendorId,
    'zone_id': zoneId,
    'delivery_address': deliveryAddress,
    if (deliveryAddressId != null) 'delivery_address_id': deliveryAddressId,
    if (deliveryLat != null) 'delivery_lat': deliveryLat,
    if (deliveryLng != null) 'delivery_lng': deliveryLng,
    'items': items.map((i) => i.toJson()).toList(),
    if (quoteId != null) 'quote_id': quoteId,
  };
}
