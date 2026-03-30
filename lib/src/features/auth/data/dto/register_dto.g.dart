// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$RegisterDtoToJson(RegisterDto instance) {
  final map = <String, dynamic>{
    'full_name': instance.fullName,
    'password': instance.password,
    'role': instance.role,
  };
  if (instance.email != null && instance.email!.isNotEmpty) {
    map['email'] = instance.email;
  }
  if (instance.phoneE164 != null && instance.phoneE164!.isNotEmpty) {
    map['phone_e164'] = instance.phoneE164;
  }
  return map;
}
