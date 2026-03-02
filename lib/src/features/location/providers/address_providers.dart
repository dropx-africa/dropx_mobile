import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/core/providers/core_providers.dart';
import 'package:dropx_mobile/src/features/location/data/address_repository.dart';
import 'package:dropx_mobile/src/features/location/data/remote_address_repository.dart';

final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return RemoteAddressRepository(apiClient);
});
