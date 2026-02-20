// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vendors_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VendorsResponse _$VendorsResponseFromJson(Map<String, dynamic> json) =>
    VendorsResponse(
      ok: json['ok'] as bool,
      vendors: (json['vendors'] as List<dynamic>)
          .map((e) => Vendor.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$VendorsResponseToJson(VendorsResponse instance) =>
    <String, dynamic>{'ok': instance.ok, 'vendors': instance.vendors};
