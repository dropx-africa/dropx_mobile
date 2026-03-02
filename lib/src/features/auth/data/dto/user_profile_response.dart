import 'package:json_annotation/json_annotation.dart';

part 'user_profile_response.g.dart';

@JsonSerializable()
class UserProfileResponse {
  @JsonKey(name: 'user_id')
  final String userId;

  final String email;

  @JsonKey(name: 'full_name')
  final String fullName;

  @JsonKey(name: 'phone_e164')
  final String phone;

  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const UserProfileResponse({
    required this.userId,
    required this.email,
    required this.fullName,
    required this.phone,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('data')) {
      return _$UserProfileResponseFromJson(
        json['data'] as Map<String, dynamic>,
      );
    }
    return _$UserProfileResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$UserProfileResponseToJson(this);
}
