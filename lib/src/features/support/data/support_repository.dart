import 'package:dropx_mobile/src/features/support/data/dto/ticket_dto.dart';

abstract class SupportRepository {
  Future<TicketResponseData> createTicket(CreateTicketDto dto);
  Future<TicketResponseData> getTicket(String id);

  /// Resolves a legacy ticket id, support case id, or dispute id to its
  /// kind and app route — used for deep links / notifications carrying an
  /// ambiguous support id.
  Future<SupportRecordSummary> resolveSupportRecord(String supportId);
}
