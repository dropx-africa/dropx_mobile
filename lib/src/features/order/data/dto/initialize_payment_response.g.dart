// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'initialize_payment_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InitializePaymentResponse _$InitializePaymentResponseFromJson(
  Map<String, dynamic> json,
) => InitializePaymentResponse(
  ok: json['ok'] as bool,
  authorizationUrl: json['authorization_url'] as String,
  reference: json['reference'] as String,
  paymentAttemptId: json['payment_attempt_id'] as String,
  orderState: json['order_state'] as String,
);

Map<String, dynamic> _$InitializePaymentResponseToJson(
  InitializePaymentResponse instance,
) => <String, dynamic>{
  'ok': instance.ok,
  'authorization_url': instance.authorizationUrl,
  'reference': instance.reference,
  'payment_attempt_id': instance.paymentAttemptId,
  'order_state': instance.orderState,
};
