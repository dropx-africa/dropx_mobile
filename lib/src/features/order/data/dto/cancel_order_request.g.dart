// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cancel_order_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CancelOrderRequest _$CancelOrderRequestFromJson(Map<String, dynamic> json) =>
    CancelOrderRequest(
      reasonCode: json['reason_code'] as String,
      note: json['note'] as String,
    );

Map<String, dynamic> _$CancelOrderRequestToJson(CancelOrderRequest instance) =>
    <String, dynamic>{
      'reason_code': instance.reasonCode,
      'note': instance.note,
    };
