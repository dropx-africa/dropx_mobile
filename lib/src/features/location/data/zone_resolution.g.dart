// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zone_resolution.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ZoneResolution _$ZoneResolutionFromJson(Map<String, dynamic> json) =>
    ZoneResolution(
      zoneId: json['zone_id'] as String?,
      displayName: json['display_name'] as String?,
      serviceable: json['serviceable'] as bool,
    );

Map<String, dynamic> _$ZoneResolutionToJson(ZoneResolution instance) =>
    <String, dynamic>{
      'zone_id': instance.zoneId,
      'display_name': instance.displayName,
      'serviceable': instance.serviceable,
    };
