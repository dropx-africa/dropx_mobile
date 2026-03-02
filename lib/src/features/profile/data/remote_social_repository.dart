import 'package:dropx_mobile/src/core/network/api_client.dart';
import 'package:dropx_mobile/src/core/network/api_endpoints.dart';
import 'package:dropx_mobile/src/features/profile/data/social_repository.dart';
import 'package:dropx_mobile/src/features/profile/data/dto/social_dto.dart';

class RemoteSocialRepository implements SocialRepository {
  final ApiClient _apiClient;

  RemoteSocialRepository(this._apiClient);

  @override
  Future<SyncContactsData> syncContacts(SyncContactsDto dto) async {
    final response = await _apiClient.post<SyncContactsData>(
      ApiEndpoints.socialContactsSync,
      data: dto.toJson(),
      headers: ApiClient.traceHeaders(),
      fromJson: (json) =>
          SyncContactsData.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  @override
  Future<SocialFeedData> getFeed() async {
    final response = await _apiClient.get<SocialFeedData>(
      ApiEndpoints.socialFeed,
      headers: ApiClient.traceHeaders(),
      fromJson: (json) => SocialFeedData.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }
}
