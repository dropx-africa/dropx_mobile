import 'package:json_annotation/json_annotation.dart';
import 'package:dropx_mobile/src/models/cost_breakdown.dart';

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

  @JsonKey(name: 'cost_breakdown')
  final CostBreakdown? costBreakdown;

  @JsonKey(name: 'zone_policy')
  final ZonePolicy? zonePolicy;

  @JsonKey(name: 'requires_acceptance')
  final bool requiresAcceptance;

  @JsonKey(name: 'route_evidence')
  final RouteEvidence? routeEvidence;

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
    this.costBreakdown,
    this.zonePolicy,
    this.requiresAcceptance = false,
    this.routeEvidence,
  });

  bool get isExpired {
    final expiry = DateTime.tryParse(expiresAt);
    return expiry != null && !expiry.isAfter(DateTime.now());
  }

  factory EstimateOrderData.fromJson(Map<String, dynamic> json) =>
      _$EstimateOrderDataFromJson(json);

  Map<String, dynamic> toJson() => _$EstimateOrderDataToJson(this);
}

/// Cross-zone delivery policy for a checkout estimate — lets the UI warn
/// the customer up front when the delivery fee is higher because pickup
/// and drop-off are in different service zones.
@JsonSerializable()
class ZonePolicy {
  @JsonKey(name: 'pickup_zone_id')
  final String? pickupZoneId;

  @JsonKey(name: 'dropoff_zone_id')
  final String? dropoffZoneId;

  @JsonKey(name: 'same_zone')
  final bool sameZone;

  @JsonKey(name: 'cross_zone')
  final bool crossZone;

  @JsonKey(name: 'requires_customer_acceptance')
  final bool requiresCustomerAcceptance;

  @JsonKey(name: 'in_vendor_scope')
  final bool inVendorScope;

  @JsonKey(name: 'enforcement_mode')
  final String? enforcementMode;

  final List<String>? warnings;

  const ZonePolicy({
    this.pickupZoneId,
    this.dropoffZoneId,
    this.sameZone = true,
    this.crossZone = false,
    this.requiresCustomerAcceptance = false,
    this.inVendorScope = true,
    this.enforcementMode,
    this.warnings,
  });

  factory ZonePolicy.fromJson(Map<String, dynamic> json) =>
      _$ZonePolicyFromJson(json);

  Map<String, dynamic> toJson() => _$ZonePolicyToJson(this);
}

/// Route distance/duration evidence backing an estimate's ETA.
@JsonSerializable()
class RouteEvidence {
  final String? source;

  @JsonKey(name: 'distance_m')
  final num? distanceM;

  @JsonKey(name: 'duration_seconds')
  final int? durationSeconds;

  final String? confidence;

  const RouteEvidence({
    this.source,
    this.distanceM,
    this.durationSeconds,
    this.confidence,
  });

  factory RouteEvidence.fromJson(Map<String, dynamic> json) =>
      _$RouteEvidenceFromJson(json);

  Map<String, dynamic> toJson() => _$RouteEvidenceToJson(this);
}
