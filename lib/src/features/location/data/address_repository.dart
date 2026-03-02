import 'package:dropx_mobile/src/features/location/data/address_models.dart';

abstract class AddressRepository {
  Future<List<AddressData>> getAddresses();
  Future<AddressData> createAddress(CreateAddressRequest request);
}
