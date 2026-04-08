import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/core/providers/core_providers.dart';
import 'package:dropx_mobile/src/features/parcel/data/parcel_repository.dart';
import 'package:dropx_mobile/src/features/parcel/data/remote_parcel_repository.dart';

final parcelRepositoryProvider = Provider<ParcelRepository>((ref) {
  return RemoteParcelRepository(ref.watch(apiClientProvider));
});
