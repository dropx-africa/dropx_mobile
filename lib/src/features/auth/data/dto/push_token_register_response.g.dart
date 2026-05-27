// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_token_register_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PushTokenData _$PushTokenDataFromJson(Map<String, dynamic> json) =>
    PushTokenData(
      pushDeviceTokenId: json['push_device_token_id'] as String,
      app: json['app'] as String,
      platform: json['platform'] as String,
      status: json['status'] as String,
    );

Map<String, dynamic> _$PushTokenDataToJson(PushTokenData instance) =>
    <String, dynamic>{
      'push_device_token_id': instance.pushDeviceTokenId,
      'app': instance.app,
      'platform': instance.platform,
      'status': instance.status,
    };
