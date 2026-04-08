// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parcel_quote_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$ParcelQuoteRequestToJson(
  ParcelQuoteRequest instance,
) => <String, dynamic>{
  'parcel_type': instance.parcelType,
  'pickup': instance.pickup.toJson(),
  'dropoff': instance.dropoff.toJson(),
  'sender': instance.sender.toJson(),
  'recipient': instance.recipient.toJson(),
  'declared_value_kobo': instance.declaredValueKobo,
  'payment_method': instance.paymentMethod,
  'notes': instance.notes,
  'is_urgent': instance.isUrgent,
};

Map<String, dynamic> _$ParcelAddressDtoToJson(
  ParcelAddressDto instance,
) => <String, dynamic>{
  'address_line': instance.addressLine,
  'lat': instance.lat,
  'lng': instance.lng,
  'landmark': instance.landmark,
  'instructions': instance.instructions,
};

Map<String, dynamic> _$ParcelContactDtoToJson(
  ParcelContactDto instance,
) => <String, dynamic>{
  'name': instance.name,
  'phone_e164': instance.phoneE164,
};
