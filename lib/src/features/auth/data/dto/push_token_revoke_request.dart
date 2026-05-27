import 'package:json_annotation/json_annotation.dart';

part 'push_token_revoke_request.g.dart';

@JsonSerializable(createFactory: false)
class PushTokenRevokeRequest {
  final String token;

  const PushTokenRevokeRequest({required this.token});

  Map<String, dynamic> toJson() => _$PushTokenRevokeRequestToJson(this);
}
