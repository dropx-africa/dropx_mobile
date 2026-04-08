// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_otp_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeliveryOtpResponse _$DeliveryOtpResponseFromJson(Map<String, dynamic> json) =>
    DeliveryOtpResponse(
      ok: json['ok'] as bool,
      data: DeliveryOtpData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DeliveryOtpResponseToJson(
  DeliveryOtpResponse instance,
) => <String, dynamic>{'ok': instance.ok, 'data': instance.data.toJson()};

DeliveryOtpData _$DeliveryOtpDataFromJson(Map<String, dynamic> json) =>
    DeliveryOtpData(
      orderId: json['order_id'] as String,
      state: json['state'] as String,
      deliveryOtp: json['delivery_otp'] as String?,
      deliveryOtpAvailable: json['delivery_otp_available'] as bool,
      issuedAt: json['issued_at'] as String?,
      expiresAt: json['expires_at'] as String?,
      channelUsed: json['channel_used'] as String?,
      deliveryStatus: json['delivery_status'] as String?,
      attemptsRemaining: (json['attempts_remaining'] as num?)?.toInt(),
    );

Map<String, dynamic> _$DeliveryOtpDataToJson(DeliveryOtpData instance) =>
    <String, dynamic>{
      'order_id': instance.orderId,
      'state': instance.state,
      'delivery_otp': instance.deliveryOtp,
      'delivery_otp_available': instance.deliveryOtpAvailable,
      'issued_at': instance.issuedAt,
      'expires_at': instance.expiresAt,
      'channel_used': instance.channelUsed,
      'delivery_status': instance.deliveryStatus,
      'attempts_remaining': instance.attemptsRemaining,
    };
