import 'package:json_annotation/json_annotation.dart';

part 'update_preferences_dto.g.dart';

@JsonSerializable(createFactory: false, includeIfNull: false)
class UpdatePreferencesDto {
  @JsonKey(name: 'marketing_opt_in')
  final bool? marketingOptIn;

  @JsonKey(name: 'show_orders_to_friends')
  final bool? showOrdersToFriends;

  @JsonKey(name: 'push_enabled')
  final bool? pushEnabled;

  const UpdatePreferencesDto({
    this.marketingOptIn,
    this.showOrdersToFriends,
    this.pushEnabled,
  });

  Map<String, dynamic> toJson() => _$UpdatePreferencesDtoToJson(this);
}
