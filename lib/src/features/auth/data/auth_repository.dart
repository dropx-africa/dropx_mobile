import 'package:dropx_mobile/src/features/auth/data/dto/auth_response.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/login_dto.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/register_dto.dart';

/// Abstract repository interface for auth operations.
abstract class AuthRepository {
  /// Login with email and password.
  Future<AuthResponse> login(LoginDto dto);

  /// Register a new user.
  Future<AuthResponse> register(RegisterDto dto);

  /// Send OTP to phone number.
  Future<bool> sendOtp(String phoneNumber);

  /// Verify OTP and get auth token.
  Future<String> verifyOtp(String phoneNumber, String otp);

  /// Check if user is currently authenticated.
  Future<bool> isAuthenticated();

  /// Get current auth token.
  Future<String?> getToken();

  /// Log out the current user.
  Future<void> logout();
}
