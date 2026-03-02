import 'package:json_annotation/json_annotation.dart';

part 'update_profile_dto.g.dart';

@JsonSerializable(createFactory: false, includeIfNull: false)
class UpdateProfileDto {
  @JsonKey(name: 'full_name')
  final String? fullName;

  final String? email;

  @JsonKey(name: 'phone_e164')
  final String? phoneE164;

  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;

  const UpdateProfileDto({
    this.fullName,
    this.email,
    this.phoneE164,
    this.avatarUrl,
  });

  Map<String, dynamic> toJson() => _$UpdateProfileDtoToJson(this);
}
