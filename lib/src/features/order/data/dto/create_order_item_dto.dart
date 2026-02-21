import 'package:json_annotation/json_annotation.dart';

part 'create_order_item_dto.g.dart';

/// A single item in a create-order request payload.
@JsonSerializable(createFactory: false)
class CreateOrderItemDto {
  final String name;
  final int qty;

  @JsonKey(name: 'unit_price_kobo')
  final int unitPriceKobo;

  const CreateOrderItemDto({
    required this.name,
    required this.qty,
    required this.unitPriceKobo,
  });

  Map<String, dynamic> toJson() => _$CreateOrderItemDtoToJson(this);
}
