// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'estimate_order_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EstimateOrderResponse _$EstimateOrderResponseFromJson(
  Map<String, dynamic> json,
) => EstimateOrderResponse(
  ok: json['ok'] as bool,
  data: EstimateOrderData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$EstimateOrderResponseToJson(
  EstimateOrderResponse instance,
) => <String, dynamic>{'ok': instance.ok, 'data': instance.data.toJson()};

EstimateOrderData _$EstimateOrderDataFromJson(Map<String, dynamic> json) =>
    EstimateOrderData(
      quoteId: json['quote_id'] as String,
      pricingSignature: json['pricing_signature'] as String,
      priceVersion: json['price_version'] as String,
      subtotalKobo: json['subtotal_kobo'] as String,
      deliveryFeeKobo: json['delivery_fee_kobo'] as String,
      serviceFeeKobo: json['service_fee_kobo'] as String,
      totalKobo: json['total_kobo'] as String,
      etaMinutes: (json['eta_minutes'] as num).toInt(),
      currency: json['currency'] as String,
      expiresAt: json['expires_at'] as String,
      unavailableItems: json['unavailable_items'] as List<dynamic>?,
    );

Map<String, dynamic> _$EstimateOrderDataToJson(EstimateOrderData instance) =>
    <String, dynamic>{
      'quote_id': instance.quoteId,
      'pricing_signature': instance.pricingSignature,
      'price_version': instance.priceVersion,
      'subtotal_kobo': instance.subtotalKobo,
      'delivery_fee_kobo': instance.deliveryFeeKobo,
      'service_fee_kobo': instance.serviceFeeKobo,
      'total_kobo': instance.totalKobo,
      'eta_minutes': instance.etaMinutes,
      'currency': instance.currency,
      'expires_at': instance.expiresAt,
      'unavailable_items': instance.unavailableItems,
    };
