// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_order_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateOrderResponse _$CreateOrderResponseFromJson(Map<String, dynamic> json) =>
    CreateOrderResponse(
      ok: json['ok'] as bool,
      order: CreateOrderSummary.fromJson(json['order'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CreateOrderResponseToJson(
  CreateOrderResponse instance,
) => <String, dynamic>{'ok': instance.ok, 'order': instance.order};

CreateOrderSummary _$CreateOrderSummaryFromJson(Map<String, dynamic> json) =>
    CreateOrderSummary(
      orderId: json['order_id'] as String,
      state: json['state'] as String,
      totalAmountKobo: json['total_amount_kobo'] as String,
    );

Map<String, dynamic> _$CreateOrderSummaryToJson(CreateOrderSummary instance) =>
    <String, dynamic>{
      'order_id': instance.orderId,
      'state': instance.state,
      'total_amount_kobo': instance.totalAmountKobo,
    };
