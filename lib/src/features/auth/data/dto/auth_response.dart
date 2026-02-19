import 'package:json_annotation/json_annotation.dart';

part 'auth_response.g.dart';

/// Response model for login and register endpoints.
///
/// Matches the actual API response:
/// ```json
/// {
///   "ok": true,
///   "user_id": "c0a8012b-3d2c-4d3a-9b7c-9a0a4a1d2f33",
///   "access_token": "<jwt>",
///   "refresh_token": "<jwt>"
/// }
/// ```
@JsonSerializable()
class AuthResponse {
  final bool ok;

  @JsonKey(name: 'user_id')
  final String userId;

  @JsonKey(name: 'access_token')
  final String accessToken;

  @JsonKey(name: 'refresh_token')
  final String refreshToken;

  const AuthResponse({
    required this.ok,
    required this.userId,
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}
