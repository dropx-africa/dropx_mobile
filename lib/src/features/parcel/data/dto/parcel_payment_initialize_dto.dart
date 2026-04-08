import 'package:json_annotation/json_annotation.dart';

part 'parcel_payment_initialize_dto.g.dart';

@JsonSerializable(createFactory: false)
class ParcelPaymentInitializeDto {
  final String provider;

  const ParcelPaymentInitializeDto({this.provider = 'paystack'});

  Map<String, dynamic> toJson() => _$ParcelPaymentInitializeDtoToJson(this);
}
