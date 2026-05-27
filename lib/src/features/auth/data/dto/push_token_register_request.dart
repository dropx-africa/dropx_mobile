import 'package:json_annotation/json_annotation.dart';

part 'push_token_register_request.g.dart';

@JsonSerializable(createFactory: false)
class PushTokenRegisterRequest {
  final String token;
  final String app;
  final String platform;

  const PushTokenRegisterRequest({
    required this.token,
    required this.app,
    required this.platform,
  });

  Map<String, dynamic> toJson() => _$PushTokenRegisterRequestToJson(this);
}
