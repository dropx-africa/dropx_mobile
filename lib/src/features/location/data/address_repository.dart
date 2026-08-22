import 'package:dropx_mobile/src/features/location/data/address_models.dart';

abstract class AddressRepository {
  Future<List<AddressData>> getAddresses();
  Future<AddressData> createAddress(CreateAddressRequest request);

  /// PATCH /me/addresses/:id/default — sets this address as the default.
  Future<void> setDefaultAddress(String addressId);

  /// PATCH /me/addresses/:id — updates label/line2/landmark/instructions.
  /// Pass only the fields that changed; omitted fields are left as-is.
  Future<void> updateAddress(
    String addressId, {
    String? label,
    String? line2,
    String? landmark,
    String? instructions,
  });

  /// DELETE /me/addresses/:id
  Future<void> deleteAddress(String addressId);
}
