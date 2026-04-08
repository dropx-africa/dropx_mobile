// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_parcel_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateParcelResponse _$CreateParcelResponseFromJson(
  Map<String, dynamic> json,
) => CreateParcelResponse(
  ok: json['ok'] as bool,
  data: CreateParcelData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CreateParcelResponseToJson(
  CreateParcelResponse instance,
) => <String, dynamic>{'ok': instance.ok, 'data': instance.data.toJson()};

CreateParcelData _$CreateParcelDataFromJson(Map<String, dynamic> json) =>
    CreateParcelData(
      parcelId: json['parcel_id'] as String,
      state: json['state'] as String,
      assignmentStatus: json['assignment_status'] as String?,
      trackingAvailable: json['tracking_available'] as bool,
      paymentRequired: json['payment_required'] as bool,
    );

Map<String, dynamic> _$CreateParcelDataToJson(CreateParcelData instance) =>
    <String, dynamic>{
      'parcel_id': instance.parcelId,
      'state': instance.state,
      'assignment_status': instance.assignmentStatus,
      'tracking_available': instance.trackingAvailable,
      'payment_required': instance.paymentRequired,
    };
