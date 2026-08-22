import 'package:json_annotation/json_annotation.dart';

part 'zone_resolution.g.dart';

/// Result of resolving a lat/lng to the zone that currently covers it —
/// used to compare a vendor's zone against the customer's zone without
/// needing a full order estimate (which requires real cart items).
@JsonSerializable()
class ZoneResolution {
  @JsonKey(name: 'zone_id')
  final String? zoneId;

  @JsonKey(name: 'display_name')
  final String? displayName;

  final bool serviceable;

  const ZoneResolution({
    this.zoneId,
    this.displayName,
    required this.serviceable,
  });

  factory ZoneResolution.fromJson(Map<String, dynamic> json) =>
      _$ZoneResolutionFromJson(json);

  Map<String, dynamic> toJson() => _$ZoneResolutionToJson(this);
}
