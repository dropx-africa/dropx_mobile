// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generate_payment_link_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeneratePaymentLinkResponse _$GeneratePaymentLinkResponseFromJson(
  Map<String, dynamic> json,
) => GeneratePaymentLinkResponse(
  ok: json['ok'] as bool,
  paymentLinkId: json['payment_link_id'] as String,
  expiresAt: json['expires_at'] as String,
  token: json['token'] as String,
  note: json['note'] as String,
);

Map<String, dynamic> _$GeneratePaymentLinkResponseToJson(
  GeneratePaymentLinkResponse instance,
) => <String, dynamic>{
  'ok': instance.ok,
  'payment_link_id': instance.paymentLinkId,
  'expires_at': instance.expiresAt,
  'token': instance.token,
  'note': instance.note,
};
