import 'package:json_annotation/json_annotation.dart';

part 'parcel_detail_response.g.dart';

@JsonSerializable(explicitToJson: true)
class ParcelDetailResponse {
  final bool ok;
  final ParcelDetail data;

  const ParcelDetailResponse({required this.ok, required this.data});

  factory ParcelDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$ParcelDetailResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ParcelDetailResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ParcelDetail {
  @JsonKey(name: 'parcel_id')
  final String parcelId;

  final String state;

  @JsonKey(name: 'assignment_status')
  final String? assignmentStatus;

  @JsonKey(name: 'tracking_available')
  final bool trackingAvailable;

  @JsonKey(name: 'payment_method')
  final String? paymentMethod;

  @JsonKey(name: 'payment_required')
  final bool paymentRequired;

  @JsonKey(name: 'fee_breakdown')
  final ParcelDetailFeeBreakdown? feeBreakdown;

  const ParcelDetail({
    required this.parcelId,
    required this.state,
    this.assignmentStatus,
    this.trackingAvailable = false,
    this.paymentMethod,
    this.paymentRequired = false,
    this.feeBreakdown,
  });

  factory ParcelDetail.fromJson(Map<String, dynamic> json) =>
      _$ParcelDetailFromJson(json);

  Map<String, dynamic> toJson() => _$ParcelDetailToJson(this);
}

@JsonSerializable()
class ParcelDetailFeeBreakdown {
  @JsonKey(name: 'delivery_fee_kobo')
  final int deliveryFeeKobo;

  @JsonKey(name: 'insurance_fee_kobo')
  final int insuranceFeeKobo;

  @JsonKey(name: 'total_kobo')
  final int totalKobo;

  const ParcelDetailFeeBreakdown({
    required this.deliveryFeeKobo,
    required this.insuranceFeeKobo,
    required this.totalKobo,
  });

  factory ParcelDetailFeeBreakdown.fromJson(Map<String, dynamic> json) =>
      _$ParcelDetailFeeBreakdownFromJson(json);

  Map<String, dynamic> toJson() => _$ParcelDetailFeeBreakdownToJson(this);
}
