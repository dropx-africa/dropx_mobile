import 'package:json_annotation/json_annotation.dart';

part 'parcel_quote_response.g.dart';

@JsonSerializable(explicitToJson: true)
class ParcelQuoteResponse {
  final bool ok;
  final ParcelQuoteData data;

  const ParcelQuoteResponse({required this.ok, required this.data});

  factory ParcelQuoteResponse.fromJson(Map<String, dynamic> json) =>
      _$ParcelQuoteResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ParcelQuoteResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ParcelQuoteData {
  @JsonKey(name: 'quote_id')
  final String quoteId;

  final String state;

  @JsonKey(name: 'distance_km')
  final double? distanceKm;

  @JsonKey(name: 'eta_minutes')
  final int? etaMinutes;

  @JsonKey(name: 'fee_breakdown')
  final ParcelFeeBreakdown feeBreakdown;

  const ParcelQuoteData({
    required this.quoteId,
    required this.state,
    this.distanceKm,
    this.etaMinutes,
    required this.feeBreakdown,
  });

  factory ParcelQuoteData.fromJson(Map<String, dynamic> json) =>
      _$ParcelQuoteDataFromJson(json);

  Map<String, dynamic> toJson() => _$ParcelQuoteDataToJson(this);
}

@JsonSerializable()
class ParcelFeeBreakdown {
  @JsonKey(name: 'delivery_fee_kobo')
  final int deliveryFeeKobo;

  @JsonKey(name: 'insurance_fee_kobo')
  final int insuranceFeeKobo;

  @JsonKey(name: 'total_kobo')
  final int totalKobo;

  const ParcelFeeBreakdown({
    required this.deliveryFeeKobo,
    required this.insuranceFeeKobo,
    required this.totalKobo,
  });

  factory ParcelFeeBreakdown.fromJson(Map<String, dynamic> json) =>
      _$ParcelFeeBreakdownFromJson(json);

  Map<String, dynamic> toJson() => _$ParcelFeeBreakdownToJson(this);
}
