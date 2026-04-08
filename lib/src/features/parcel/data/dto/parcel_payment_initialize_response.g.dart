// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parcel_payment_initialize_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParcelPaymentInitializeResponse _$ParcelPaymentInitializeResponseFromJson(
  Map<String, dynamic> json,
) => ParcelPaymentInitializeResponse(
  ok: json['ok'] as bool,
  data: ParcelPaymentInitializeData.fromJson(
    json['data'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$ParcelPaymentInitializeResponseToJson(
  ParcelPaymentInitializeResponse instance,
) => <String, dynamic>{'ok': instance.ok, 'data': instance.data.toJson()};

ParcelPaymentInitializeData _$ParcelPaymentInitializeDataFromJson(
  Map<String, dynamic> json,
) => ParcelPaymentInitializeData(
  authorizationUrl: json['authorization_url'] as String,
  reference: json['reference'] as String,
  paymentAttemptId: json['payment_attempt_id'] as String?,
);

Map<String, dynamic> _$ParcelPaymentInitializeDataToJson(
  ParcelPaymentInitializeData instance,
) => <String, dynamic>{
  'authorization_url': instance.authorizationUrl,
  'reference': instance.reference,
  'payment_attempt_id': instance.paymentAttemptId,
};
