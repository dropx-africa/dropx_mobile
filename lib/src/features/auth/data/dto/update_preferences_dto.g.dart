// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_preferences_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$UpdatePreferencesDtoToJson(
  UpdatePreferencesDto instance,
) => <String, dynamic>{
  if (instance.marketingOptIn case final value?) 'marketing_opt_in': value,
  if (instance.showOrdersToFriends case final value?)
    'show_orders_to_friends': value,
  if (instance.pushEnabled case final value?) 'push_enabled': value,
  if (instance.emailEnabled case final value?) 'email_enabled': value,
  if (instance.smsEnabled case final value?) 'sms_enabled': value,
  if (instance.orderUpdatesEnabled case final value?)
    'order_updates_enabled': value,
  if (instance.promotionsEnabled case final value?) 'promotions_enabled': value,
  if (instance.systemAlertsEnabled case final value?)
    'system_alerts_enabled': value,
};
