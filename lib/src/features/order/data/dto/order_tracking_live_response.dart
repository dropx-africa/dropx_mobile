import 'package:json_annotation/json_annotation.dart';

part 'order_tracking_live_response.g.dart';

@JsonSerializable(explicitToJson: true)
class OrderTrackingLiveResponse {
  final bool ok;
  final OrderTrackingLiveData data;

  const OrderTrackingLiveResponse({required this.ok, required this.data});

  factory OrderTrackingLiveResponse.fromJson(Map<String, dynamic> json) =>
      _$OrderTrackingLiveResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OrderTrackingLiveResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class OrderTrackingLiveData {
  @JsonKey(name: 'order_id')
  final String orderId;

  final String state;
  final OrderTrackingRider? rider;

  @JsonKey(name: 'eta_minutes')
  final int? etaMinutes;

  @JsonKey(name: 'delivery_otp')
  final String? deliveryOtp;

  final OrderTrackingLocation? location;
  final List<dynamic>? timeline;

  @JsonKey(name: 'stale_after_seconds')
  final int? staleAfterSeconds;

  @JsonKey(name: 'is_stale')
  final bool? isStale;

  final String? source;

  @JsonKey(name: 'accuracy_m')
  final num? accuracyM;

  @JsonKey(name: 'last_event_seq')
  final int? lastEventSeq;

  const OrderTrackingLiveData({
    required this.orderId,
    required this.state,
    this.rider,
    this.etaMinutes,
    this.deliveryOtp,
    this.location,
    this.timeline,
    this.staleAfterSeconds,
    this.isStale,
    this.source,
    this.accuracyM,
    this.lastEventSeq,
  });

  factory OrderTrackingLiveData.fromJson(Map<String, dynamic> json) =>
      _$OrderTrackingLiveDataFromJson(json);

  Map<String, dynamic> toJson() => _$OrderTrackingLiveDataToJson(this);
}

@JsonSerializable()
class OrderTrackingRider {
  final String id;
  final String name;

  const OrderTrackingRider({required this.id, required this.name});

  factory OrderTrackingRider.fromJson(Map<String, dynamic> json) =>
      _$OrderTrackingRiderFromJson(json);

  Map<String, dynamic> toJson() => _$OrderTrackingRiderToJson(this);
}

@JsonSerializable()
class OrderTrackingLocation {
  final double lat;
  final double lng;

  @JsonKey(name: 'updated_at')
  final String updatedAt;

  final String? source;

  @JsonKey(name: 'accuracy_m')
  final num? accuracyM;

  const OrderTrackingLocation({
    required this.lat,
    required this.lng,
    required this.updatedAt,
    this.source,
    this.accuracyM,
  });

  factory OrderTrackingLocation.fromJson(Map<String, dynamic> json) =>
      _$OrderTrackingLocationFromJson(json);

  Map<String, dynamic> toJson() => _$OrderTrackingLocationToJson(this);
}
