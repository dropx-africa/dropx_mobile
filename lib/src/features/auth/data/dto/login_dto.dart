import 'package:json_annotation/json_annotation.dart';

part 'login_dto.g.dart';

/// Request payload for the login endpoint.
///
/// Uses [createFactory: false] because this DTO is only serialized
/// (sent to the API), never deserialized from a response.
@JsonSerializable(createFactory: false)
class LoginDto {
  final String email;
  final String password;

  const LoginDto({required this.email, required this.password});

  Map<String, dynamic> toJson() => _$LoginDtoToJson(this);
}
