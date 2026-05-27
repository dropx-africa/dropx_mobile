import 'package:json_annotation/json_annotation.dart';

part 'user_preferences_response.g.dart';

@JsonSerializable()
class UserPreferencesResponse {
  @JsonKey(name: 'marketing_opt_in')
  final bool marketingOptIn;

  @JsonKey(name: 'show_orders_to_friends')
  final bool showOrdersToFriends;

  @JsonKey(name: 'push_enabled')
  final bool pushEnabled;

  @JsonKey(name: 'email_enabled')
  final bool emailEnabled;

  @JsonKey(name: 'sms_enabled')
  final bool smsEnabled;

  @JsonKey(name: 'order_updates_enabled')
  final bool orderUpdatesEnabled;

  @JsonKey(name: 'promotions_enabled')
  final bool promotionsEnabled;

  @JsonKey(name: 'system_alerts_enabled')
  final bool systemAlertsEnabled;

  const UserPreferencesResponse({
    required this.marketingOptIn,
    required this.showOrdersToFriends,
    required this.pushEnabled,
    required this.emailEnabled,
    required this.smsEnabled,
    required this.orderUpdatesEnabled,
    required this.promotionsEnabled,
    required this.systemAlertsEnabled,
  });

  factory UserPreferencesResponse.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('data')) {
      return _$UserPreferencesResponseFromJson(
        json['data'] as Map<String, dynamic>,
      );
    }
    return _$UserPreferencesResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$UserPreferencesResponseToJson(this);
}
