// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_tracking_live_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderTrackingLiveResponse _$OrderTrackingLiveResponseFromJson(
  Map<String, dynamic> json,
) => OrderTrackingLiveResponse(
  ok: json['ok'] as bool,
  data: OrderTrackingLiveData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$OrderTrackingLiveResponseToJson(
  OrderTrackingLiveResponse instance,
) => <String, dynamic>{'ok': instance.ok, 'data': instance.data.toJson()};

OrderTrackingLiveData _$OrderTrackingLiveDataFromJson(
  Map<String, dynamic> json,
) {
  // live-summary nests telemetry inside a 'tracking' sub-object.
  // Fall back to the root so the old /tracking-live shape still works.
  final t = json['tracking'] as Map<String, dynamic>? ?? json;

  // delivery_otp is a plain String on /tracking-live but an object on
  // live-summary. Extract safely either way.
  final rawOtp = json['delivery_otp'];
  final String? deliveryOtp = rawOtp is String
      ? rawOtp
      : (rawOtp is Map) ? rawOtp['otp'] as String? : null;

  // location lives at the root on /tracking-live, inside 'tracking' on live-summary.
  final rawLoc = t['location'] ?? json['location'];

  return OrderTrackingLiveData(
    orderId: json['order_id'] as String,
    state: json['state'] as String,
    rider: json['rider'] == null
        ? null
        : OrderTrackingRider.fromJson(json['rider'] as Map<String, dynamic>),
    etaMinutes: (json['eta_minutes'] as num?)?.toInt(),
    deliveryOtp: deliveryOtp,
    location: rawLoc == null
        ? null
        : OrderTrackingLocation.fromJson(rawLoc as Map<String, dynamic>),
    timeline: json['timeline'] as List<dynamic>?,
    staleAfterSeconds: (t['stale_after_seconds'] as num?)?.toInt(),
    isStale: t['is_stale'] as bool?,
    source: t['source'] as String?,
    accuracyM: t['accuracy_m'] as num?,
    lastEventSeq: (json['last_event_seq'] as num?)?.toInt(),
  );
}

Map<String, dynamic> _$OrderTrackingLiveDataToJson(
  OrderTrackingLiveData instance,
) => <String, dynamic>{
  'order_id': instance.orderId,
  'state': instance.state,
  'rider': instance.rider?.toJson(),
  'eta_minutes': instance.etaMinutes,
  'delivery_otp': instance.deliveryOtp,
  'location': instance.location?.toJson(),
  'timeline': instance.timeline,
  'stale_after_seconds': instance.staleAfterSeconds,
  'is_stale': instance.isStale,
  'source': instance.source,
  'accuracy_m': instance.accuracyM,
  'last_event_seq': instance.lastEventSeq,
};

OrderTrackingRider _$OrderTrackingRiderFromJson(Map<String, dynamic> json) =>
    OrderTrackingRider(
      id: json['id'] as String,
      name: json['name'] as String,
      phoneE164: json['phone_e164'] as String?,
      photoUrl: json['photo_url'] as String?,
      vehicle: json['vehicle'] as String?,
      plateNumber: json['plate_number'] as String?,
      rating: json['rating'] as num?,
    );

Map<String, dynamic> _$OrderTrackingRiderToJson(OrderTrackingRider instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone_e164': instance.phoneE164,
      'photo_url': instance.photoUrl,
      'vehicle': instance.vehicle,
      'plate_number': instance.plateNumber,
      'rating': instance.rating,
    };

OrderTrackingLocation _$OrderTrackingLocationFromJson(
  Map<String, dynamic> json,
) => OrderTrackingLocation(
  lat: (json['lat'] as num).toDouble(),
  lng: (json['lng'] as num).toDouble(),
  updatedAt: json['updated_at'] as String,
  source: json['source'] as String?,
  accuracyM: json['accuracy_m'] as num?,
);

Map<String, dynamic> _$OrderTrackingLocationToJson(
  OrderTrackingLocation instance,
) => <String, dynamic>{
  'lat': instance.lat,
  'lng': instance.lng,
  'updated_at': instance.updatedAt,
  'source': instance.source,
  'accuracy_m': instance.accuracyM,
};
