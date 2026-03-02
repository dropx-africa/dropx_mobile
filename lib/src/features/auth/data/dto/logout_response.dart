import 'package:json_annotation/json_annotation.dart';

part 'logout_response.g.dart';

@JsonSerializable()
class LogoutData {
  @JsonKey(name: 'revoked_count')
  final int revokedCount;

  const LogoutData({required this.revokedCount});

  factory LogoutData.fromJson(Map<String, dynamic> json) =>
      _$LogoutDataFromJson(json);

  Map<String, dynamic> toJson() => _$LogoutDataToJson(this);
}
