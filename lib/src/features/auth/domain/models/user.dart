import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

/// User model used across the auth feature.
///
/// Uses [json_serializable] for type-safe JSON parsing.
@JsonSerializable()
class User {
  final String id;
  final String email;

  @JsonKey(name: 'full_name')
  final String? fullName;

  @JsonKey(name: 'phone_e164')
  final String? phoneE164;

  final String role;

  const User({
    required this.id,
    required this.email,
    this.fullName,
    this.phoneE164,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
