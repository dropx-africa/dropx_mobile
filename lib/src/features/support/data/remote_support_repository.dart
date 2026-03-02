import 'package:dropx_mobile/src/core/network/api_client.dart';
import 'package:dropx_mobile/src/core/network/api_endpoints.dart';
import 'package:dropx_mobile/src/features/support/data/support_repository.dart';
import 'package:dropx_mobile/src/features/support/data/dto/ticket_dto.dart';

class RemoteSupportRepository implements SupportRepository {
  final ApiClient _apiClient;

  RemoteSupportRepository(this._apiClient);

  @override
  Future<TicketResponseData> createTicket(CreateTicketDto dto) async {
    final response = await _apiClient.post<TicketResponseData>(
      ApiEndpoints.supportTickets,
      data: dto.toJson(),
      headers: ApiClient.traceHeaders(),
      fromJson: (json) =>
          TicketResponseData.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  @override
  Future<TicketResponseData> getTicket(String id) async {
    final response = await _apiClient.get<TicketResponseData>(
      ApiEndpoints.supportTicketById(id),
      headers: ApiClient.traceHeaders(),
      fromJson: (json) =>
          TicketResponseData.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }
}
