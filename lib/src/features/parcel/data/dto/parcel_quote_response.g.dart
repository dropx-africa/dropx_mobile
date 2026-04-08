// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parcel_quote_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParcelQuoteResponse _$ParcelQuoteResponseFromJson(
  Map<String, dynamic> json,
) => ParcelQuoteResponse(
  ok: json['ok'] as bool,
  data: ParcelQuoteData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ParcelQuoteResponseToJson(
  ParcelQuoteResponse instance,
) => <String, dynamic>{'ok': instance.ok, 'data': instance.data.toJson()};

ParcelQuoteData _$ParcelQuoteDataFromJson(Map<String, dynamic> json) =>
    ParcelQuoteData(
      quoteId: json['quote_id'] as String,
      state: json['state'] as String,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      etaMinutes: (json['eta_minutes'] as num?)?.toInt(),
      feeBreakdown: ParcelFeeBreakdown.fromJson(
        json['fee_breakdown'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$ParcelQuoteDataToJson(ParcelQuoteData instance) =>
    <String, dynamic>{
      'quote_id': instance.quoteId,
      'state': instance.state,
      'distance_km': instance.distanceKm,
      'eta_minutes': instance.etaMinutes,
      'fee_breakdown': instance.feeBreakdown.toJson(),
    };

ParcelFeeBreakdown _$ParcelFeeBreakdownFromJson(Map<String, dynamic> json) =>
    ParcelFeeBreakdown(
      deliveryFeeKobo: (json['delivery_fee_kobo'] as num).toInt(),
      insuranceFeeKobo: (json['insurance_fee_kobo'] as num).toInt(),
      totalKobo: (json['total_kobo'] as num).toInt(),
    );

Map<String, dynamic> _$ParcelFeeBreakdownToJson(
  ParcelFeeBreakdown instance,
) => <String, dynamic>{
  'delivery_fee_kobo': instance.deliveryFeeKobo,
  'insurance_fee_kobo': instance.insuranceFeeKobo,
  'total_kobo': instance.totalKobo,
};
