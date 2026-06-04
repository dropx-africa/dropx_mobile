import 'package:flutter/foundation.dart';
import 'package:dropx_mobile/src/core/network/api_client.dart';
import 'package:dropx_mobile/src/core/network/api_endpoints.dart';
import 'package:dropx_mobile/src/features/profile/data/social_repository.dart';
import 'package:dropx_mobile/src/features/profile/data/dto/social_dto.dart';

class RemoteSocialRepository implements SocialRepository {
  final ApiClient _apiClient;

  RemoteSocialRepository(this._apiClient);

  @override
  Future<SyncContactsData> syncContacts(SyncContactsDto dto) async {
    debugPrint('📇 [ContactSync] POST ${ApiEndpoints.socialContactsSync} — hashes=${dto.hashedContacts.length}');
    try {
      final response = await _apiClient.post<SyncContactsData>(
        ApiEndpoints.socialContactsSync,
        data: dto.toJson(),
        headers: ApiClient.traceHeaders(),
        fromJson: (json) =>
            SyncContactsData.fromJson(json as Map<String, dynamic>),
      );
      debugPrint('📇 [ContactSync] ✅ sync success — received=${response.data.receivedCount} synced=${response.data.syncedCount}');
      return response.data;
    } catch (e) {
      debugPrint('📇 [ContactSync] ❌ sync failed: $e');
      rethrow;
    }
  }

  @override
  Future<SocialFeedData> getFeed() async {
    debugPrint('📰 [SocialFeed] GET ${ApiEndpoints.socialFeed}');
    try {
      final response = await _apiClient.get<SocialFeedData>(
        ApiEndpoints.socialFeed,
        headers: ApiClient.traceHeaders(),
        fromJson: (json) => SocialFeedData.fromJson(json as Map<String, dynamic>),
      );
      debugPrint('📰 [SocialFeed] ✅ fetched ${response.data.events.length} events');
      return response.data;
    } catch (e) {
      debugPrint('📰 [SocialFeed] ❌ fetch failed: $e');
      rethrow;
    }
  }
}
