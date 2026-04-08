import 'package:json_annotation/json_annotation.dart';

part 'cart_dto.g.dart';

// ─── GET /me/cart response ────────────────────────────────────────────────

@JsonSerializable(explicitToJson: true)
class ServerCartResponse {
  final bool ok;
  final ServerCartData data;

  const ServerCartResponse({required this.ok, required this.data});

  factory ServerCartResponse.fromJson(Map<String, dynamic> json) =>
      _$ServerCartResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ServerCartResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ServerCartData {
  @JsonKey(name: 'vendor_id')
  final String? vendorId;

  @JsonKey(name: 'zone_id')
  final String? zoneId;

  final List<ServerCartItem> items;

  const ServerCartData({
    this.vendorId,
    this.zoneId,
    this.items = const [],
  });

  factory ServerCartData.fromJson(Map<String, dynamic> json) =>
      _$ServerCartDataFromJson(json);

  Map<String, dynamic> toJson() => _$ServerCartDataToJson(this);
}

@JsonSerializable()
class ServerCartItem {
  @JsonKey(name: 'item_id')
  final String itemId;

  final String name;
  final int qty;

  @JsonKey(name: 'unit_price_kobo')
  final int unitPriceKobo;

  const ServerCartItem({
    required this.itemId,
    required this.name,
    required this.qty,
    required this.unitPriceKobo,
  });

  factory ServerCartItem.fromJson(Map<String, dynamic> json) =>
      _$ServerCartItemFromJson(json);

  Map<String, dynamic> toJson() => _$ServerCartItemToJson(this);
}

// ─── PATCH /me/cart body ─────────────────────────────────────────────────

@JsonSerializable(createFactory: false, explicitToJson: true)
class CartSyncDto {
  @JsonKey(name: 'vendor_id')
  final String vendorId;

  @JsonKey(name: 'zone_id')
  final String zoneId;

  final List<CartSyncItem> items;

  const CartSyncDto({
    required this.vendorId,
    required this.zoneId,
    required this.items,
  });

  Map<String, dynamic> toJson() => _$CartSyncDtoToJson(this);
}

@JsonSerializable(createFactory: false)
class CartSyncItem {
  @JsonKey(name: 'item_id')
  final String itemId;

  final String name;
  final int qty;

  @JsonKey(name: 'unit_price_kobo')
  final int unitPriceKobo;

  const CartSyncItem({
    required this.itemId,
    required this.name,
    required this.qty,
    required this.unitPriceKobo,
  });

  Map<String, dynamic> toJson() => _$CartSyncItemToJson(this);
}
