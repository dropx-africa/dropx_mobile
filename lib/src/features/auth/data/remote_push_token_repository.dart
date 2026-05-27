import 'dart:io' show Platform;
import 'package:dropx_mobile/src/core/network/api_client.dart';
import 'package:dropx_mobile/src/core/network/api_endpoints.dart';
import 'package:dropx_mobile/src/features/auth/data/push_token_repository.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/push_token_register_request.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/push_token_register_response.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/push_token_revoke_request.dart';

class RemotePushTokenRepository implements PushTokenRepository {
  final ApiClient _apiClient;

  RemotePushTokenRepository(this._apiClient);

  /// Resolves the platform string the backend expects.
  static String get _platform {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'web';
  }

  @override
  Future<PushTokenData> registerToken(String token) async {
    final response = await _apiClient.post<PushTokenData>(
      ApiEndpoints.pushTokens,
      data: PushTokenRegisterRequest(
        token: token,
        app: 'customer',
        platform: _platform,
      ).toJson(),
      headers: ApiClient.traceHeaders(),
      fromJson: (json) =>
          PushTokenData.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  @override
  Future<void> revokeToken(String token) async {
    await _apiClient.delete(
      ApiEndpoints.pushTokens,
      data: PushTokenRevokeRequest(token: token).toJson(),
      headers: ApiClient.traceHeaders(),
    );
  }
}
