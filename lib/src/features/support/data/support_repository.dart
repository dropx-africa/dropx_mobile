import 'package:dropx_mobile/src/features/support/data/dto/ticket_dto.dart';

abstract class SupportRepository {
  Future<TicketResponseData> createTicket(CreateTicketDto dto);
  Future<TicketResponseData> getTicket(String id);
}
