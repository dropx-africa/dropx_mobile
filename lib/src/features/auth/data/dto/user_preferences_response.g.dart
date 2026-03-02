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
);

Map<String, dynamic> _$UserPreferencesResponseToJson(
  UserPreferencesResponse instance,
) => <String, dynamic>{
  'marketing_opt_in': instance.marketingOptIn,
  'show_orders_to_friends': instance.showOrdersToFriends,
  'push_enabled': instance.pushEnabled,
};
