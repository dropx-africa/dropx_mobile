// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dispute_order_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DisputeOrderResponse _$DisputeOrderResponseFromJson(
  Map<String, dynamic> json,
) => DisputeOrderResponse(
  ok: json['ok'] as bool,
  data: DisputeOrderData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$DisputeOrderResponseToJson(
  DisputeOrderResponse instance,
) => <String, dynamic>{'ok': instance.ok, 'data': instance.data.toJson()};

DisputeOrderData _$DisputeOrderDataFromJson(Map<String, dynamic> json) =>
    DisputeOrderData(
      disputeId: json['dispute_id'] as String,
      orderId: json['order_id'] as String,
      status: json['status'] as String,
    );

Map<String, dynamic> _$DisputeOrderDataToJson(DisputeOrderData instance) =>
    <String, dynamic>{
      'dispute_id': instance.disputeId,
      'order_id': instance.orderId,
      'status': instance.status,
    };
