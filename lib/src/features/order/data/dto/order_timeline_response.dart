import 'package:json_annotation/json_annotation.dart';

part 'order_timeline_response.g.dart';

@JsonSerializable(explicitToJson: true)
class OrderTimelineResponse {
  final bool ok;
  @JsonKey(name: 'order_id')
  final String orderId;
  final String state;
  final dynamic rider;
  @JsonKey(name: 'eta_minutes')
  final int? etaMinutes;
  final List<TimelineEvent> timeline;
  final dynamic location;

  const OrderTimelineResponse({
    required this.ok,
    required this.orderId,
    required this.state,
    this.rider,
    this.etaMinutes,
    required this.timeline,
    this.location,
  });

  factory OrderTimelineResponse.fromJson(Map<String, dynamic> json) =>
      _$OrderTimelineResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OrderTimelineResponseToJson(this);
}

@JsonSerializable()
class TimelineEvent {
  final String? ts;
  final String? event;
  final String? status;

  const TimelineEvent({this.ts, this.event, this.status});

  factory TimelineEvent.fromJson(Map<String, dynamic> json) =>
      _$TimelineEventFromJson(json);

  Map<String, dynamic> toJson() => _$TimelineEventToJson(this);
}
