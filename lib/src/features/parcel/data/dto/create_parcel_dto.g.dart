// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_parcel_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$CreateParcelDtoToJson(CreateParcelDto instance) =>
    <String, dynamic>{
      'quote_id': instance.quoteId,
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
