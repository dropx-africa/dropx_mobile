import 'package:dropx_mobile/src/core/network/api_client.dart';
import 'package:dropx_mobile/src/core/network/api_endpoints.dart';
import 'package:dropx_mobile/src/features/location/data/address_models.dart';
import 'package:dropx_mobile/src/features/location/data/address_repository.dart';

class RemoteAddressRepository implements AddressRepository {
  final ApiClient _apiClient;

  const RemoteAddressRepository(this._apiClient);

  @override
  Future<List<AddressData>> getAddresses() async {
    final response = await _apiClient.get<GetAddressesResponse>(
      ApiEndpoints.addresses,
      headers: ApiClient.traceHeaders(),
      fromJson: (json) =>
          GetAddressesResponse.fromJson(json as Map<String, dynamic>),
    );
    return response.data.addresses;
  }

  @override
  Future<AddressData> createAddress(CreateAddressRequest request) async {
    final response = await _apiClient.post<CreateAddressResponse>(
      ApiEndpoints.addresses,
      data: request.toJson(),
      headers: ApiClient.traceHeaders(),
      fromJson: (json) =>
          CreateAddressResponse.fromJson(json as Map<String, dynamic>),
    );
    return response.data.address;
  }

  @override
  Future<void> setDefaultAddress(String addressId) async {
    await _apiClient.patch<Map<String, dynamic>>(
      ApiEndpoints.addressSetDefault(addressId),
      data: const <String, dynamic>{},
      headers: ApiClient.traceHeaders(),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  @override
  Future<void> updateAddress(
    String addressId, {
    String? label,
    String? line2,
    String? landmark,
    String? instructions,
  }) async {
    await _apiClient.patch<Map<String, dynamic>>(
      ApiEndpoints.addressById(addressId),
      data: {
        if (label != null) 'label': label,
        if (line2 != null) 'line2': line2,
        if (landmark != null) 'landmark': landmark,
        if (instructions != null) 'instructions': instructions,
      },
      headers: ApiClient.traceHeaders(),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  @override
  Future<void> deleteAddress(String addressId) async {
    await _apiClient.delete(
      ApiEndpoints.addressById(addressId),
      headers: ApiClient.traceHeaders(),
    );
  }
}
