import 'package:json_annotation/json_annotation.dart';

part 'parcel_quote_request.g.dart';

@JsonSerializable(createFactory: false, explicitToJson: true)
class ParcelQuoteRequest {
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

  const ParcelQuoteRequest({
    required this.parcelType,
    required this.pickup,
    required this.dropoff,
    required this.sender,
    required this.recipient,
    required this.declaredValueKobo,
    this.paymentMethod = 'CARD_TRANSFER_USSD',
    this.notes,
    this.isUrgent = false,
  });

  Map<String, dynamic> toJson() => _$ParcelQuoteRequestToJson(this);
}

@JsonSerializable(createFactory: false, explicitToJson: true)
class ParcelAddressDto {
  @JsonKey(name: 'address_line')
  final String addressLine;

  final double? lat;
  final double? lng;
  final String? landmark;
  final String? instructions;

  const ParcelAddressDto({
    required this.addressLine,
    this.lat,
    this.lng,
    this.landmark,
    this.instructions,
  });

  Map<String, dynamic> toJson() => _$ParcelAddressDtoToJson(this);
}

@JsonSerializable(createFactory: false, explicitToJson: true)
class ParcelContactDto {
  final String name;

  @JsonKey(name: 'phone_e164')
  final String phoneE164;

  const ParcelContactDto({required this.name, required this.phoneE164});

  Map<String, dynamic> toJson() => _$ParcelContactDtoToJson(this);
}
