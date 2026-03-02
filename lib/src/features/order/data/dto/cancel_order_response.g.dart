// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cancel_order_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CancelOrderResponse _$CancelOrderResponseFromJson(Map<String, dynamic> json) =>
    CancelOrderResponse(
      ok: json['ok'] as bool,
      data: CancelOrderData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CancelOrderResponseToJson(
  CancelOrderResponse instance,
) => <String, dynamic>{'ok': instance.ok, 'data': instance.data.toJson()};

CancelOrderData _$CancelOrderDataFromJson(Map<String, dynamic> json) =>
    CancelOrderData(
      orderId: json['order_id'] as String,
      state: json['state'] as String,
    );

Map<String, dynamic> _$CancelOrderDataToJson(CancelOrderData instance) =>
    <String, dynamic>{'order_id': instance.orderId, 'state': instance.state};
