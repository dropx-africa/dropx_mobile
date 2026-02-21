import 'package:dropx_mobile/src/core/network/api_client.dart';
import 'package:dropx_mobile/src/core/network/api_endpoints.dart';
import 'package:dropx_mobile/src/features/paylink/data/dto/initialize_pay_link_dto.dart';
import 'package:dropx_mobile/src/features/paylink/data/dto/initialize_pay_link_response.dart';
import 'package:dropx_mobile/src/features/paylink/data/dto/pay_link_details_response.dart';
import 'package:dropx_mobile/src/features/paylink/data/pay_link_repository.dart';

class RemotePayLinkRepository implements PayLinkRepository {
  final ApiClient _apiClient;

  RemotePayLinkRepository(this._apiClient);

  @override
  Future<PayLinkDetailsResponse> getPayLinkDetails(String token) async {
    final response = await _apiClient.get<PayLinkDetailsResponse>(
      ApiEndpoints.payLinkDetails(token),
      fromJson: (json) =>
          PayLinkDetailsResponse.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  @override
  Future<InitializePayLinkResponse> initializePayLink(
    String token,
    InitializePayLinkDto dto,
  ) async {
    final response = await _apiClient.post<InitializePayLinkResponse>(
      ApiEndpoints.initializePayLink(token),
      data: dto.toJson(),
      headers: ApiClient.traceHeaders(),
      fromJson: (json) =>
          InitializePayLinkResponse.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }
}
