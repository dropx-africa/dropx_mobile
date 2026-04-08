import 'package:json_annotation/json_annotation.dart';
import 'package:dropx_mobile/src/features/parcel/data/dto/parcel_quote_request.dart';

part 'create_parcel_dto.g.dart';

@JsonSerializable(createFactory: false, explicitToJson: true)
class CreateParcelDto {
  @JsonKey(name: 'quote_id')
  final String quoteId;

  @JsonKey(name: 'parcel_type')
  final String parcelType;

  final ParcelAddressDto pickup;
  final ParcelAddressDto dropoff;

  final ParcelContactDto sender;
  final ParcelContactDto recipient;

  @JsonKey(name: 'declared_value_kobo')
  final int declaredValueKobo;

  @JsonKey(name: 'payment_method')
  final String paymentMethod;

  final String? notes;

  @JsonKey(name: 'is_urgent')
  final bool isUrgent;

  const CreateParcelDto({
    required this.quoteId,
    required this.parcelType,
    required this.pickup,
    required this.dropoff,
    required this.sender,
    required this.recipient,
    required this.declaredValueKobo,
    required this.paymentMethod,
    this.notes,
    this.isUrgent = false,
  });

  Map<String, dynamic> toJson() => _$CreateParcelDtoToJson(this);
}
