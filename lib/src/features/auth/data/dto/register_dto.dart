import 'package:json_annotation/json_annotation.dart';

part 'register_dto.g.dart';

/// Request payload for the register endpoint.
///
/// Uses [createFactory: false] because this DTO is only serialized
/// (sent to the API), never deserialized from a response.
@JsonSerializable(createFactory: false)
class RegisterDto {
  final String email;

  @JsonKey(name: 'phone_e164')
  final String? phoneE164;

  @JsonKey(name: 'full_name')
  final String? fullName;

  final String password;
  final String role;

  const RegisterDto({
    required this.email,
    this.phoneE164,
    this.fullName,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toJson() => _$RegisterDtoToJson(this);
}
