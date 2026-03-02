// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_timeline_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderTimelineResponse _$OrderTimelineResponseFromJson(
  Map<String, dynamic> json,
) => OrderTimelineResponse(
  ok: json['ok'] as bool,
  orderId: json['order_id'] as String,
  state: json['state'] as String,
  rider: json['rider'],
  etaMinutes: (json['eta_minutes'] as num?)?.toInt(),
  timeline: (json['timeline'] as List<dynamic>)
      .map((e) => TimelineEvent.fromJson(e as Map<String, dynamic>))
      .toList(),
  location: json['location'],
);

Map<String, dynamic> _$OrderTimelineResponseToJson(
  OrderTimelineResponse instance,
) => <String, dynamic>{
  'ok': instance.ok,
  'order_id': instance.orderId,
  'state': instance.state,
  'rider': instance.rider,
  'eta_minutes': instance.etaMinutes,
  'timeline': instance.timeline.map((e) => e.toJson()).toList(),
  'location': instance.location,
};

TimelineEvent _$TimelineEventFromJson(Map<String, dynamic> json) =>
    TimelineEvent(
      ts: json['ts'] as String?,
      event: json['event'] as String?,
      status: json['status'] as String?,
    );

Map<String, dynamic> _$TimelineEventToJson(TimelineEvent instance) =>
    <String, dynamic>{
      'ts': instance.ts,
      'event': instance.event,
      'status': instance.status,
    };
