// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddressData _$AddressDataFromJson(Map<String, dynamic> json) => AddressData(
  addressId: json['address_id'] as String,
  userId: json['user_id'] as String,
  label: json['label'] as String,
  line1: json['line1'] as String,
  line2: json['line2'] as String?,
  city: json['city'] as String,
  state: json['state'] as String,
  lat: (json['lat'] as num).toDouble(),
  lng: (json['lng'] as num).toDouble(),
  landmark: json['landmark'] as String?,
  instructions: json['instructions'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$AddressDataToJson(AddressData instance) =>
    <String, dynamic>{
      'address_id': instance.addressId,
      'user_id': instance.userId,
      'label': instance.label,
      'line1': instance.line1,
      'line2': instance.line2,
      'city': instance.city,
      'state': instance.state,
      'lat': instance.lat,
      'lng': instance.lng,
      'landmark': instance.landmark,
      'instructions': instance.instructions,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

GetAddressesResponse _$GetAddressesResponseFromJson(
  Map<String, dynamic> json,
) => GetAddressesResponse(
  ok: json['ok'] as bool,
  addresses: (json['addresses'] as List<dynamic>)
      .map((e) => AddressData.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GetAddressesResponseToJson(
  GetAddressesResponse instance,
) => <String, dynamic>{
  'ok': instance.ok,
  'addresses': instance.addresses.map((e) => e.toJson()).toList(),
};

CreateAddressRequest _$CreateAddressRequestFromJson(
  Map<String, dynamic> json,
) => CreateAddressRequest(
  label: json['label'] as String,
  line1: json['line1'] as String,
  line2: json['line2'] as String?,
  city: json['city'] as String,
  state: json['state'] as String,
  lat: (json['lat'] as num).toDouble(),
  lng: (json['lng'] as num).toDouble(),
  landmark: json['landmark'] as String?,
  instructions: json['instructions'] as String?,
);

Map<String, dynamic> _$CreateAddressRequestToJson(
  CreateAddressRequest instance,
) => <String, dynamic>{
  'label': instance.label,
  'line1': instance.line1,
  'line2': instance.line2,
  'city': instance.city,
  'state': instance.state,
  'lat': instance.lat,
  'lng': instance.lng,
  'landmark': instance.landmark,
  'instructions': instance.instructions,
};

CreateAddressResponse _$CreateAddressResponseFromJson(
  Map<String, dynamic> json,
) => CreateAddressResponse(
  ok: json['ok'] as bool,
  address: AddressData.fromJson(json['address'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CreateAddressResponseToJson(
  CreateAddressResponse instance,
) => <String, dynamic>{'ok': instance.ok, 'address': instance.address.toJson()};
