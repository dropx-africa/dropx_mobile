import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/core/providers/core_providers.dart';
import 'package:dropx_mobile/src/features/paylink/data/pay_link_repository.dart';
import 'package:dropx_mobile/src/features/paylink/data/remote_pay_link_repository.dart';

final payLinkRepositoryProvider = Provider<PayLinkRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return RemotePayLinkRepository(apiClient);
});
