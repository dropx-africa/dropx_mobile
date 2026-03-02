import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/core/providers/core_providers.dart';
import 'package:dropx_mobile/src/features/support/data/support_repository.dart';
import 'package:dropx_mobile/src/features/support/data/remote_support_repository.dart';
import 'package:dropx_mobile/src/features/support/data/dto/ticket_dto.dart';

final supportRepositoryProvider = Provider<SupportRepository>((ref) {
  return RemoteSupportRepository(ref.watch(apiClientProvider));
});

final supportTicketDetailFutureProvider =
    FutureProvider.family<TicketResponseData, String>((ref, id) {
      return ref.watch(supportRepositoryProvider).getTicket(id);
    });
