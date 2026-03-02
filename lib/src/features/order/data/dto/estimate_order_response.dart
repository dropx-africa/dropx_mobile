import 'package:json_annotation/json_annotation.dart';

part 'estimate_order_response.g.dart';

@JsonSerializable(explicitToJson: true)
class EstimateOrderResponse {
  final bool ok;
  final EstimateOrderData data;

  const EstimateOrderResponse({required this.ok, required this.data});

  factory EstimateOrderResponse.fromJson(Map<String, dynamic> json) =>
      _$EstimateOrderResponseFromJson(json);

  Map<String, dynamic> toJson() => _$EstimateOrderResponseToJson(this);
}

@JsonSerializable()
class EstimateOrderData {
  @JsonKey(name: 'quote_id')
  final String quoteId;

  @JsonKey(name: 'pricing_signature')
  final String pricingSignature;

  @JsonKey(name: 'price_version')
  final String priceVersion;

  @JsonKey(name: 'subtotal_kobo')
  final String subtotalKobo;

  @JsonKey(name: 'delivery_fee_kobo')
  final String deliveryFeeKobo;

  @JsonKey(name: 'service_fee_kobo')
  final String serviceFeeKobo;

  @JsonKey(name: 'total_kobo')
  final String totalKobo;

  @JsonKey(name: 'eta_minutes')
  final int etaMinutes;

  final String currency;

  @JsonKey(name: 'expires_at')
  final String expiresAt;

  @JsonKey(name: 'unavailable_items')
  final List<dynamic>? unavailableItems;

  const EstimateOrderData({
    required this.quoteId,
    required this.pricingSignature,
    required this.priceVersion,
    required this.subtotalKobo,
    required this.deliveryFeeKobo,
    required this.serviceFeeKobo,
    required this.totalKobo,
    required this.etaMinutes,
    required this.currency,
    required this.expiresAt,
    this.unavailableItems,
  });

  factory EstimateOrderData.fromJson(Map<String, dynamic> json) =>
      _$EstimateOrderDataFromJson(json);

  Map<String, dynamic> toJson() => _$EstimateOrderDataToJson(this);
}
