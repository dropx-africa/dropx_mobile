import 'package:dropx_mobile/src/features/auth/data/auth_repository.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/auth_response.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/login_dto.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/register_dto.dart';

/// Mock implementation of [AuthRepository] for development.
class MockAuthRepository implements AuthRepository {
  bool _isAuthenticated = false;
  String _token = '';

  @override
  Future<AuthResponse> login(LoginDto dto) async {
    await Future.delayed(const Duration(seconds: 1));
    _isAuthenticated = true;
    _token = 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}';
    return AuthResponse(
      ok: true,
      userId: 'mock_id_123',
      accessToken: _token,
      refreshToken: 'mock_refresh_token',
    );
  }

  @override
  Future<AuthResponse> register(RegisterDto dto) async {
    await Future.delayed(const Duration(seconds: 1));
    _isAuthenticated = true;
    _token = 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}';
    return AuthResponse(
      ok: true,
      userId: 'mock_id_456',
      accessToken: _token,
      refreshToken: 'mock_refresh_token',
    );
  }

  @override
  Future<bool> sendOtp(String phoneNumber) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true; // Always succeeds in mock
  }

  @override
  Future<String> verifyOtp(String phoneNumber, String otp) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _isAuthenticated = true;
    _token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
    return _token;
  }

  @override
  Future<bool> isAuthenticated() async {
    return _isAuthenticated;
  }

  @override
  Future<String?> getToken() async {
    return _isAuthenticated ? _token : null;
  }

  @override
  Future<void> logout() async {
    _isAuthenticated = false;
    _token = '';
  }
}
