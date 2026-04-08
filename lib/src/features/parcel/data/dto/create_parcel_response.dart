import 'package:json_annotation/json_annotation.dart';

part 'create_parcel_response.g.dart';

@JsonSerializable(explicitToJson: true)
class CreateParcelResponse {
  final bool ok;
  final CreateParcelData data;

  const CreateParcelResponse({required this.ok, required this.data});

  factory CreateParcelResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateParcelResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CreateParcelResponseToJson(this);
}

@JsonSerializable()
class CreateParcelData {
  @JsonKey(name: 'parcel_id')
  final String parcelId;

  final String state;

  @JsonKey(name: 'assignment_status')
  final String? assignmentStatus;

  @JsonKey(name: 'tracking_available')
  final bool trackingAvailable;

  @JsonKey(name: 'payment_required')
  final bool paymentRequired;

  const CreateParcelData({
    required this.parcelId,
    required this.state,
    this.assignmentStatus,
    required this.trackingAvailable,
    required this.paymentRequired,
  });

  factory CreateParcelData.fromJson(Map<String, dynamic> json) =>
      _$CreateParcelDataFromJson(json);

  Map<String, dynamic> toJson() => _$CreateParcelDataToJson(this);
}
