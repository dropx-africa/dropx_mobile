import 'package:json_annotation/json_annotation.dart';
import 'package:dropx_mobile/src/features/order/data/dto/create_order_item_dto.dart';

part 'create_order_dto.g.dart';

/// Request payload for `POST /orders`.
@JsonSerializable(createFactory: false)
class CreateOrderDto {
  @JsonKey(name: 'vendor_id')
  final String vendorId;

  @JsonKey(name: 'zone_id')
  final String zoneId;

  @JsonKey(name: 'delivery_address')
  final String deliveryAddress;

  final List<CreateOrderItemDto> items;

  const CreateOrderDto({
    required this.vendorId,
    required this.zoneId,
    required this.deliveryAddress,
    required this.items,
  });

  Map<String, dynamic> toJson() => _$CreateOrderDtoToJson(this);
}
