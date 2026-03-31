import 'package:dropx_mobile/src/features/auth/data/dto/auth_response.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/login_dto.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/register_dto.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/otp_request_dto.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/otp_resend_dto.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/otp_verify_dto.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/otp_challenge_response.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/otp_verify_response.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/refresh_token_response.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/logout_response.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/user_profile_response.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/update_profile_dto.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/user_preferences_response.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/update_preferences_dto.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/password_reset_request_dto.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/password_reset_challenge_response.dart';

/// Abstract repository interface for auth operations.
abstract class AuthRepository {
  /// Login with email and password.
  Future<AuthResponse> login(LoginDto dto);

  /// Register a new user.
  Future<AuthResponse> register(RegisterDto dto);

  /// Request OTP for phone number authentication.
  Future<OtpChallengeResponse> requestOtp(OtpRequestDto dto);

  /// Resend OTP challenge.
  Future<OtpChallengeResponse> resendOtp(OtpResendDto dto);

  /// Verify OTP and get auth tokens.
  Future<OtpVerifyResponse> verifyOtp(OtpVerifyDto dto);

  /// Refresh the access token using a refresh token.
  Future<RefreshTokenData> refreshToken(String refreshToken);

  /// Log out the current user.
  Future<LogoutData> logout(String refreshToken, {bool allDevices = false});

  /// Check if user is currently authenticated.
  Future<bool> isAuthenticated();

  /// Get current auth token.
  Future<String?> getToken();

  /// Get the current user's profile.
  Future<UserProfileResponse> getProfile();

  /// Update the current user's profile.
  Future<UserProfileResponse> updateProfile(UpdateProfileDto dto);

  /// Get the current user's preferences.
  Future<UserPreferencesResponse> getPreferences();

  /// Update the current user's preferences.
  Future<UserPreferencesResponse> updatePreferences(UpdatePreferencesDto dto);

  /// Complete password reset via /auth/password/reset/complete.
  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  });

  /// Verify a password-reset OTP via /auth/password/reset/verify.
  /// Returns the reset_token needed to complete the password reset.
  Future<String> verifyPasswordResetOtp({
    required String otpChallengeId,
    required String otp,
    String audience = 'customer',
  });

  /// Request a password reset OTP via /auth/password/reset/request.
  Future<PasswordResetChallengeResponse> requestPasswordReset(
    PasswordResetRequestDto dto,
  );
}
