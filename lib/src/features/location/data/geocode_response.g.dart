// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geocode_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeocodeResponse _$GeocodeResponseFromJson(Map<String, dynamic> json) =>
    GeocodeResponse(
      ok: json['ok'] as bool,
      query: json['query'] as String?,
      results:
          (json['results'] as List<dynamic>?)
              ?.map((e) => GeocodeResult.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$GeocodeResponseToJson(GeocodeResponse instance) =>
    <String, dynamic>{
      'ok': instance.ok,
      'query': instance.query,
      'results': instance.results,
    };
