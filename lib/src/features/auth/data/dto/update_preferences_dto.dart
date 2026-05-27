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

  @JsonKey(name: 'email_enabled')
  final bool? emailEnabled;

  @JsonKey(name: 'sms_enabled')
  final bool? smsEnabled;

  @JsonKey(name: 'order_updates_enabled')
  final bool? orderUpdatesEnabled;

  @JsonKey(name: 'promotions_enabled')
  final bool? promotionsEnabled;

  @JsonKey(name: 'system_alerts_enabled')
  final bool? systemAlertsEnabled;

  const UpdatePreferencesDto({
    this.marketingOptIn,
    this.showOrdersToFriends,
    this.pushEnabled,
    this.emailEnabled,
    this.smsEnabled,
    this.orderUpdatesEnabled,
    this.promotionsEnabled,
    this.systemAlertsEnabled,
  });

  Map<String, dynamic> toJson() => _$UpdatePreferencesDtoToJson(this);
}
