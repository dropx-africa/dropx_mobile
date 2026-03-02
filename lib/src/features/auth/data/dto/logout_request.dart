import 'package:json_annotation/json_annotation.dart';

part 'logout_request.g.dart';

@JsonSerializable(createFactory: false)
class LogoutRequest {
  @JsonKey(name: 'refresh_token')
  final String refreshToken;

  @JsonKey(name: 'all_devices')
  final bool allDevices;

  const LogoutRequest({required this.refreshToken, this.allDevices = false});

  Map<String, dynamic> toJson() => _$LogoutRequestToJson(this);
}
