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
}
