// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pay_link_details_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PayLinkDetailsResponse _$PayLinkDetailsResponseFromJson(
  Map<String, dynamic> json,
) => PayLinkDetailsResponse(
  ok: json['ok'] as bool,
  orderId: json['order_id'] as String,
  amountKobo: json['amount_kobo'] as String,
  currency: json['currency'] as String,
  expiresAt: json['expires_at'] as String,
  status: json['status'] as String,
);

Map<String, dynamic> _$PayLinkDetailsResponseToJson(
  PayLinkDetailsResponse instance,
) => <String, dynamic>{
  'ok': instance.ok,
  'order_id': instance.orderId,
  'amount_kobo': instance.amountKobo,
  'currency': instance.currency,
  'expires_at': instance.expiresAt,
  'status': instance.status,
};
