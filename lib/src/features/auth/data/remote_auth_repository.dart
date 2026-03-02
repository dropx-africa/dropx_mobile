import 'package:flutter/foundation.dart';
import 'package:dropx_mobile/src/core/network/api_client.dart';
import 'package:dropx_mobile/src/core/network/api_endpoints.dart';
import 'package:dropx_mobile/src/features/auth/data/auth_repository.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/auth_response.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/login_dto.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/register_dto.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/otp_request_dto.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/otp_resend_dto.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/otp_verify_dto.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/otp_challenge_response.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/otp_verify_response.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/refresh_token_request.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/refresh_token_response.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/logout_request.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/logout_response.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/user_profile_response.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/update_profile_dto.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/user_preferences_response.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/update_preferences_dto.dart';

class RemoteAuthRepository implements AuthRepository {
  final ApiClient _apiClient;

  RemoteAuthRepository(this._apiClient);

  @override
  Future<AuthResponse> login(LoginDto dto) async {
    final response = await _apiClient.post<AuthResponse>(
      ApiEndpoints.login,
      data: dto.toJson(),
      headers: ApiClient.traceHeaders(),
      fromJson: (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  @override
  Future<AuthResponse> register(RegisterDto dto) async {
    if (kDebugMode) {
      print('[RemoteAuthRepo] register() called with: ${dto.toJson()}');
    }
    try {
      final response = await _apiClient.post<AuthResponse>(
        ApiEndpoints.register,
        data: dto.toJson(),
        headers: ApiClient.traceHeaders(),
        fromJson: (json) {
          if (kDebugMode) {
            print('[RemoteAuthRepo] Raw register response JSON: $json');
          }
          return AuthResponse.fromJson(json as Map<String, dynamic>);
        },
      );
      if (kDebugMode) {
        print('[RemoteAuthRepo] register() success');
      }
      return response.data;
    } catch (e, st) {
      if (kDebugMode) {
        print('[RemoteAuthRepo] register() ERROR: $e');
        print('[RemoteAuthRepo] register() Stack: $st');
      }
      rethrow;
    }
  }

  @override
  Future<OtpChallengeResponse> requestOtp(OtpRequestDto dto) async {
    if (kDebugMode) {
      print('[RemoteAuthRepo] requestOtp() called with: ${dto.toJson()}');
    }
    final response = await _apiClient.post<OtpChallengeResponse>(
      ApiEndpoints.requestOtp,
      data: dto.toJson(),
      headers: ApiClient.traceHeaders(),
      fromJson: (json) =>
          OtpChallengeResponse.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  @override
  Future<OtpChallengeResponse> resendOtp(OtpResendDto dto) async {
    if (kDebugMode) {
      print('[RemoteAuthRepo] resendOtp() called with: ${dto.toJson()}');
    }
    final response = await _apiClient.post<OtpChallengeResponse>(
      ApiEndpoints.resendOtp,
      data: dto.toJson(),
      headers: ApiClient.traceHeaders(),
      fromJson: (json) =>
          OtpChallengeResponse.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  @override
  Future<OtpVerifyResponse> verifyOtp(OtpVerifyDto dto) async {
    if (kDebugMode) {
      print('[RemoteAuthRepo] verifyOtp() called with: ${dto.toJson()}');
    }
    final response = await _apiClient.post<OtpVerifyResponse>(
      ApiEndpoints.verifyOtp,
      data: dto.toJson(),
      headers: ApiClient.traceHeaders(),
      fromJson: (json) =>
          OtpVerifyResponse.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  @override
  Future<RefreshTokenData> refreshToken(String refreshToken) async {
    debugPrint(
      '🔄 [AUTH-API] POST ${ApiEndpoints.baseUrl}${ApiEndpoints.refreshToken}',
    );
    final request = RefreshTokenRequest(refreshToken: refreshToken);
    final response = await _apiClient.post<RefreshTokenData>(
      ApiEndpoints.refreshToken,
      data: request.toJson(),
      headers: ApiClient.traceHeaders(),
      fromJson: (json) =>
          RefreshTokenData.fromJson(json as Map<String, dynamic>),
    );
    debugPrint(
      '✅ [AUTH-API] POST /auth/refresh → expires_in=${response.data.expiresIn}s',
    );
    return response.data;
  }

  @override
  Future<LogoutData> logout(
    String refreshToken, {
    bool allDevices = false,
  }) async {
    debugPrint(
      '🔴 [AUTH-API] POST ${ApiEndpoints.baseUrl}${ApiEndpoints.logout}',
    );
    final request = LogoutRequest(
      refreshToken: refreshToken,
      allDevices: allDevices,
    );
    final response = await _apiClient.post<LogoutData>(
      ApiEndpoints.logout,
      data: request.toJson(),
      headers: ApiClient.traceHeaders(),
      fromJson: (json) => LogoutData.fromJson(json as Map<String, dynamic>),
    );
    debugPrint(
      '✅ [AUTH-API] POST /auth/logout → revoked_count=${response.data.revokedCount}',
    );
    return response.data;
  }

  @override
  Future<bool> isAuthenticated() async {
    // TODO: Check Token Storage
    return false;
  }

  @override
  Future<String?> getToken() async {
    // TODO: Get from Storage
    return null;
  }

  @override
  Future<UserProfileResponse> getProfile() async {
    debugPrint('➡ [AUTH-API] GET /me/profile');
    final response = await _apiClient.get<UserProfileResponse>(
      ApiEndpoints.profile,
      headers: ApiClient.traceHeaders(),
      fromJson: (json) =>
          UserProfileResponse.fromJson(json as Map<String, dynamic>),
    );
    debugPrint('✅ [AUTH-API] GET /me/profile → id=${response.data.userId}');
    return response.data;
  }

  @override
  Future<UserProfileResponse> updateProfile(UpdateProfileDto dto) async {
    debugPrint('➡ [AUTH-API] PATCH /me/profile');
    final response = await _apiClient.patch<UserProfileResponse>(
      ApiEndpoints.profile,
      data: dto.toJson(),
      headers: ApiClient.traceHeaders(),
      fromJson: (json) =>
          UserProfileResponse.fromJson(json as Map<String, dynamic>),
    );
    debugPrint('✅ [AUTH-API] PATCH /me/profile → id=${response.data.userId}');
    return response.data;
  }

  @override
  Future<UserPreferencesResponse> getPreferences() async {
    debugPrint('➡ [AUTH-API] GET /me/preferences');
    final response = await _apiClient.get<UserPreferencesResponse>(
      ApiEndpoints.preferences,
      headers: ApiClient.traceHeaders(),
      fromJson: (json) =>
          UserPreferencesResponse.fromJson(json as Map<String, dynamic>),
    );
    debugPrint(
      '✅ [AUTH-API] GET /me/preferences → optIn=${response.data.marketingOptIn}',
    );
    return response.data;
  }

  @override
  Future<UserPreferencesResponse> updatePreferences(
    UpdatePreferencesDto dto,
  ) async {
    debugPrint('➡ [AUTH-API] PATCH /me/preferences');
    final response = await _apiClient.patch<UserPreferencesResponse>(
      ApiEndpoints.preferences,
      data: dto.toJson(),
      headers: ApiClient.traceHeaders(),
      fromJson: (json) =>
          UserPreferencesResponse.fromJson(json as Map<String, dynamic>),
    );
    debugPrint(
      '✅ [AUTH-API] PATCH /me/preferences → optIn=${response.data.marketingOptIn}',
    );
    return response.data;
  }
}
