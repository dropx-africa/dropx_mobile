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

EstimateOrderData _$EstimateOrderDataFromJson(
  Map<String, dynamic> json,
) => EstimateOrderData(
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
  costBreakdown: json['cost_breakdown'] == null
      ? null
      : CostBreakdown.fromJson(json['cost_breakdown'] as Map<String, dynamic>),
  zonePolicy: json['zone_policy'] == null
      ? null
      : ZonePolicy.fromJson(json['zone_policy'] as Map<String, dynamic>),
  requiresAcceptance: json['requires_acceptance'] as bool? ?? false,
  routeEvidence: json['route_evidence'] == null
      ? null
      : RouteEvidence.fromJson(json['route_evidence'] as Map<String, dynamic>),
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
      'cost_breakdown': instance.costBreakdown,
      'zone_policy': instance.zonePolicy,
      'requires_acceptance': instance.requiresAcceptance,
      'route_evidence': instance.routeEvidence,
    };

ZonePolicy _$ZonePolicyFromJson(Map<String, dynamic> json) => ZonePolicy(
  pickupZoneId: json['pickup_zone_id'] as String?,
  dropoffZoneId: json['dropoff_zone_id'] as String?,
  sameZone: json['same_zone'] as bool? ?? true,
  crossZone: json['cross_zone'] as bool? ?? false,
  requiresCustomerAcceptance:
      json['requires_customer_acceptance'] as bool? ?? false,
  inVendorScope: json['in_vendor_scope'] as bool? ?? true,
  enforcementMode: json['enforcement_mode'] as String?,
  warnings: (json['warnings'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$ZonePolicyToJson(ZonePolicy instance) =>
    <String, dynamic>{
      'pickup_zone_id': instance.pickupZoneId,
      'dropoff_zone_id': instance.dropoffZoneId,
      'same_zone': instance.sameZone,
      'cross_zone': instance.crossZone,
      'requires_customer_acceptance': instance.requiresCustomerAcceptance,
      'in_vendor_scope': instance.inVendorScope,
      'enforcement_mode': instance.enforcementMode,
      'warnings': instance.warnings,
    };

RouteEvidence _$RouteEvidenceFromJson(Map<String, dynamic> json) =>
    RouteEvidence(
      source: json['source'] as String?,
      distanceM: json['distance_m'] as num?,
      durationSeconds: (json['duration_seconds'] as num?)?.toInt(),
      confidence: json['confidence'] as String?,
    );

Map<String, dynamic> _$RouteEvidenceToJson(RouteEvidence instance) =>
    <String, dynamic>{
      'source': instance.source,
      'distance_m': instance.distanceM,
      'duration_seconds': instance.durationSeconds,
      'confidence': instance.confidence,
    };
