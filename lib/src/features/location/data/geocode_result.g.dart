// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geocode_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeocodeResult _$GeocodeResultFromJson(Map<String, dynamic> json) =>
    GeocodeResult(
      placeId: json['place_id'] as String,
      formattedAddress: json['formatted_address'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      provider: json['provider'] as String?,
    );

Map<String, dynamic> _$GeocodeResultToJson(GeocodeResult instance) =>
    <String, dynamic>{
      'place_id': instance.placeId,
      'formatted_address': instance.formattedAddress,
      'lat': instance.lat,
      'lng': instance.lng,
      'provider': instance.provider,
    };
