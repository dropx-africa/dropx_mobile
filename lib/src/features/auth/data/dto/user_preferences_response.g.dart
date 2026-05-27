// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPreferencesResponse _$UserPreferencesResponseFromJson(
  Map<String, dynamic> json,
) => UserPreferencesResponse(
  marketingOptIn: json['marketing_opt_in'] as bool,
  showOrdersToFriends: json['show_orders_to_friends'] as bool,
  pushEnabled: json['push_enabled'] as bool,
  emailEnabled: json['email_enabled'] as bool,
  smsEnabled: json['sms_enabled'] as bool,
  orderUpdatesEnabled: json['order_updates_enabled'] as bool,
  promotionsEnabled: json['promotions_enabled'] as bool,
  systemAlertsEnabled: json['system_alerts_enabled'] as bool,
);

Map<String, dynamic> _$UserPreferencesResponseToJson(
  UserPreferencesResponse instance,
) => <String, dynamic>{
  'marketing_opt_in': instance.marketingOptIn,
  'show_orders_to_friends': instance.showOrdersToFriends,
  'push_enabled': instance.pushEnabled,
  'email_enabled': instance.emailEnabled,
  'sms_enabled': instance.smsEnabled,
  'order_updates_enabled': instance.orderUpdatesEnabled,
  'promotions_enabled': instance.promotionsEnabled,
  'system_alerts_enabled': instance.systemAlertsEnabled,
};
