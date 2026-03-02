// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dispute_order_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DisputeOrderRequest _$DisputeOrderRequestFromJson(Map<String, dynamic> json) =>
    DisputeOrderRequest(
      reasonCode: json['reason_code'] as String,
      details: json['details'] as String,
      evidenceUrls: (json['evidence_urls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$DisputeOrderRequestToJson(
  DisputeOrderRequest instance,
) => <String, dynamic>{
  'reason_code': instance.reasonCode,
  'details': instance.details,
  'evidence_urls': instance.evidenceUrls,
};
