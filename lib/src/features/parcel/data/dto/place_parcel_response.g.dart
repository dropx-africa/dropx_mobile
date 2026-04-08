// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_parcel_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlaceParcelResponse _$PlaceParcelResponseFromJson(Map<String, dynamic> json) =>
    PlaceParcelResponse(
      ok: json['ok'] as bool,
      data: PlaceParcelData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PlaceParcelResponseToJson(
  PlaceParcelResponse instance,
) => <String, dynamic>{'ok': instance.ok, 'data': instance.data.toJson()};

PlaceParcelData _$PlaceParcelDataFromJson(Map<String, dynamic> json) =>
    PlaceParcelData(
      parcelId: json['parcel_id'] as String,
      state: json['state'] as String,
      paymentMethod: json['payment_method'] as String?,
      totalKobo: (json['total_kobo'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PlaceParcelDataToJson(PlaceParcelData instance) =>
    <String, dynamic>{
      'parcel_id': instance.parcelId,
      'state': instance.state,
      'payment_method': instance.paymentMethod,
      'total_kobo': instance.totalKobo,
    };
