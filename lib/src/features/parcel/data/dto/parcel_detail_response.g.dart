// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parcel_detail_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParcelDetailResponse _$ParcelDetailResponseFromJson(
  Map<String, dynamic> json,
) => ParcelDetailResponse(
  ok: json['ok'] as bool,
  data: ParcelDetail.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ParcelDetailResponseToJson(
  ParcelDetailResponse instance,
) => <String, dynamic>{'ok': instance.ok, 'data': instance.data.toJson()};

ParcelDetail _$ParcelDetailFromJson(Map<String, dynamic> json) => ParcelDetail(
  parcelId: json['parcel_id'] as String,
  state: json['state'] as String,
  assignmentStatus: json['assignment_status'] as String?,
  trackingAvailable: json['tracking_available'] as bool? ?? false,
  paymentMethod: json['payment_method'] as String?,
  paymentRequired: json['payment_required'] as bool? ?? false,
  feeBreakdown: json['fee_breakdown'] == null
      ? null
      : ParcelDetailFeeBreakdown.fromJson(
          json['fee_breakdown'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ParcelDetailToJson(ParcelDetail instance) =>
    <String, dynamic>{
      'parcel_id': instance.parcelId,
      'state': instance.state,
      'assignment_status': instance.assignmentStatus,
      'tracking_available': instance.trackingAvailable,
      'payment_method': instance.paymentMethod,
      'payment_required': instance.paymentRequired,
      'fee_breakdown': instance.feeBreakdown?.toJson(),
    };

ParcelDetailFeeBreakdown _$ParcelDetailFeeBreakdownFromJson(
  Map<String, dynamic> json,
) => ParcelDetailFeeBreakdown(
  deliveryFeeKobo: json['delivery_fee_kobo'] as int,
  insuranceFeeKobo: json['insurance_fee_kobo'] as int,
  totalKobo: json['total_kobo'] as int,
);

Map<String, dynamic> _$ParcelDetailFeeBreakdownToJson(
  ParcelDetailFeeBreakdown instance,
) => <String, dynamic>{
  'delivery_fee_kobo': instance.deliveryFeeKobo,
  'insurance_fee_kobo': instance.insuranceFeeKobo,
  'total_kobo': instance.totalKobo,
};
