import 'package:json_annotation/json_annotation.dart';

part 'address_models.g.dart';

@JsonSerializable(explicitToJson: true)
class AddressData {
  @JsonKey(name: 'address_id')
  final String addressId;
  @JsonKey(name: 'user_id')
  final String userId;
  final String label;
  final String line1;
  final String? line2;
  final String city;
  final String state;
  final double lat;
  final double lng;
  final String? landmark;
  final String? instructions;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  const AddressData({
    required this.addressId,
    required this.userId,
    required this.label,
    required this.line1,
    this.line2,
    required this.city,
    required this.state,
    required this.lat,
    required this.lng,
    this.landmark,
    this.instructions,
    this.createdAt,
    this.updatedAt,
  });

  factory AddressData.fromJson(Map<String, dynamic> json) =>
      _$AddressDataFromJson(json);

  Map<String, dynamic> toJson() => _$AddressDataToJson(this);
}

@JsonSerializable(explicitToJson: true)
class GetAddressesResponse {
  final bool ok;
  final List<AddressData> addresses;

  const GetAddressesResponse({required this.ok, required this.addresses});

  factory GetAddressesResponse.fromJson(Map<String, dynamic> json) =>
      _$GetAddressesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GetAddressesResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CreateAddressRequest {
  final String label;
  final String line1;
  final String? line2;
  final String city;
  final String state;
  final double lat;
  final double lng;
  final String? landmark;
  final String? instructions;

  const CreateAddressRequest({
    required this.label,
    required this.line1,
    this.line2,
    required this.city,
    required this.state,
    required this.lat,
    required this.lng,
    this.landmark,
    this.instructions,
  });

  factory CreateAddressRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateAddressRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateAddressRequestToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CreateAddressResponse {
  final bool ok;
  final AddressData address;

  const CreateAddressResponse({required this.ok, required this.address});

  factory CreateAddressResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateAddressResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CreateAddressResponseToJson(this);
}
