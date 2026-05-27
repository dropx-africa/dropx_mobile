import 'package:json_annotation/json_annotation.dart';

part 'push_token_register_response.g.dart';

@JsonSerializable()
class PushTokenData {
  @JsonKey(name: 'push_device_token_id')
  final String pushDeviceTokenId;
  final String app;
  final String platform;
  final String status;

  const PushTokenData({
    required this.pushDeviceTokenId,
    required this.app,
    required this.platform,
    required this.status,
  });

  factory PushTokenData.fromJson(Map<String, dynamic> json) =>
      _$PushTokenDataFromJson(json);

  Map<String, dynamic> toJson() => _$PushTokenDataToJson(this);
}
