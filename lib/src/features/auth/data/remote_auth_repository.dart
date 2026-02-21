import 'package:flutter/foundation.dart';
import 'package:dropx_mobile/src/core/network/api_client.dart';
import 'package:dropx_mobile/src/core/network/api_endpoints.dart';
import 'package:dropx_mobile/src/features/auth/data/auth_repository.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/auth_response.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/login_dto.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/register_dto.dart';

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
            print('[RemoteAuthRepo] JSON type: ${json.runtimeType}');
            if (json is Map<String, dynamic>) {
              print('[RemoteAuthRepo] Keys: ${json.keys.toList()}');
              print(
                '[RemoteAuthRepo] user_id: ${json['user_id']} (${json['user_id'].runtimeType})',
              );
              print(
                '[RemoteAuthRepo] access_token: ${json['access_token'] != null ? 'present' : 'NULL'}',
              );
              print(
                '[RemoteAuthRepo] refresh_token: ${json['refresh_token'] != null ? 'present' : 'NULL'}',
              );
            }
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
        print('[RemoteAuthRepo] register() ERROR type: ${e.runtimeType}');
        print('[RemoteAuthRepo] register() Stack: $st');
      }
      rethrow;
    }
  }

  @override
  Future<bool> sendOtp(String phoneNumber) async {
    // TODO: Implement actual API call
    throw UnimplementedError();
  }

  @override
  Future<String> verifyOtp(String phoneNumber, String otp) async {
    // TODO: Implement actual API call
    throw UnimplementedError();
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
  Future<void> logout() async {
    // TODO: Clear Storage
  }
}
