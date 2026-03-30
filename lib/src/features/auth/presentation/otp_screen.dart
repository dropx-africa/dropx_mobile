import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/utils/app_log.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/constants/app_icons.dart';
import 'package:dropx_mobile/src/common_widgets/custom_button.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/app_spacers.dart';
import 'package:dropx_mobile/src/common_widgets/app_image.dart';
import 'package:dropx_mobile/src/common_widgets/app_otp_field.dart';
import 'package:dropx_mobile/src/common_widgets/app_toast.dart';
import 'package:dropx_mobile/src/common_widgets/app_scaffold.dart';
import 'package:dropx_mobile/src/common_widgets/app_appbar.dart';
import 'package:dropx_mobile/src/route/page.dart';
import 'package:dropx_mobile/src/utils/app_navigator.dart';
import 'package:dropx_mobile/src/core/network/api_client.dart';
import 'package:dropx_mobile/src/core/network/api_exceptions.dart';
import 'package:dropx_mobile/src/core/providers/core_providers.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/otp_verify_dto.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/otp_resend_dto.dart';
import 'package:dropx_mobile/src/features/auth/providers/auth_providers.dart';

class OtpScreen extends ConsumerStatefulWidget {
  /// The phone number or email address the code was sent to.
  final String sentTo;

  /// Channel returned by the API: "sms" | "email" — determines the UI label.
  final String channel;

  final String otpChallengeId;

  /// ISO-8601 timestamp from `resend_available_at` — drives the resend timer.
  final String? resendAvailableAt;

  /// Whether this OTP is for forgot password flow.
  final bool isForgotPassword;

  const OtpScreen({
    super.key,
    required this.sentTo,
    required this.channel,
    required this.otpChallengeId,
    this.resendAvailableAt,
    this.isForgotPassword = false,
  });

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _otpError;
  bool _isLoading = false;
  bool _isResending = false;

  late String _otpChallengeId;

  Timer? _resendTimer;
  int _resendCountdown = 0;

  @override
  void initState() {
    super.initState();
    _otpChallengeId = widget.otpChallengeId;
    _startResendCountdown(widget.resendAvailableAt);
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startResendCountdown(String? resendAvailableAt) {
    _resendTimer?.cancel();

    if (resendAvailableAt == null) {
      setState(() => _resendCountdown = 60);
    } else {
      try {
        final resendAt = DateTime.parse(resendAvailableAt);
        final diff = resendAt.difference(DateTime.now().toUtc()).inSeconds;
        setState(() => _resendCountdown = diff > 0 ? diff : 0);
      } catch (_) {
        setState(() => _resendCountdown = 60);
      }
    }

    if (_resendCountdown > 0) {
      _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_resendCountdown <= 1) {
          timer.cancel();
          if (mounted) setState(() => _resendCountdown = 0);
        } else {
          if (mounted) setState(() => _resendCountdown--);
        }
      });
    }
  }

  // ── Verify OTP ────────────────────────────────────────────────
  Future<void> _verifyOtp() async {
    final pin = _pinController.text.trim();

    if (pin.length != 6 || !RegExp(r'^\d{6}$').hasMatch(pin)) {
      setState(() => _otpError = 'Please enter a valid 6-digit code');
      return;
    }

    setState(() {
      _otpError = null;
      _isLoading = true;
    });

    try {
      final dto = OtpVerifyDto(otpChallengeId: _otpChallengeId, otp: pin);

      AppLog.d('[OTP] Verifying: ${dto.toJson()}');

      final response = await ref.read(authRepositoryProvider).verifyOtp(dto);

      AppLog.d('[OTP] Verified — userId: ${response.userId}');

      ApiClient().setAuthToken(
        response.accessToken,
        refreshToken: response.refreshToken,
      );
      final session = ref.read(sessionServiceProvider);
      await session.saveAuthSession(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        userId: response.userId,
      );

      if (mounted) {
        AppToast.showSuccess(context, 'OTP verified successfully!');
        if (widget.isForgotPassword) {
          // Navigate to reset password screen
          AppNavigator.pushReplacement(
            context,
            AppRoute.resetPassword,
            arguments: {'otpChallengeId': _otpChallengeId, 'otp': pin},
          );
        } else {
          if (session.hasConfirmedLocation) {
            AppNavigator.pushReplacement(context, AppRoute.dashboard);
          } else {
            AppNavigator.pushReplacement(context, AppRoute.manualLocation);
          }
        }
      }
    } on ApiException catch (e) {
      AppLog.d('[OTP] ApiException: ${e.message}');
      if (mounted) setState(() => _otpError = e.message);
    } catch (e) {
      AppLog.d('[OTP] Unexpected error: $e');
      if (mounted) {
        setState(() => _otpError = 'Verification failed. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Resend OTP ────────────────────────────────────────────────
  Future<void> _resendOtp() async {
    if (_resendCountdown > 0 || _isResending) return;

    setState(() => _isResending = true);

    try {
      final dto = OtpResendDto(otpChallengeId: _otpChallengeId);

      AppLog.d('[OTP] Resending: ${dto.toJson()}');

      final challenge = await ref.read(authRepositoryProvider).resendOtp(dto);

      _otpChallengeId = challenge.otpChallengeId;
      _pinController.clear();
      _startResendCountdown(challenge.resendAvailableAt);

      if (mounted) {
        AppToast.showSuccess(context, 'OTP resent successfully!');
        setState(() => _otpError = null);
      }
    } on ApiException catch (e) {
      AppLog.d('[OTP] Resend ApiException: ${e.message}');
      if (mounted) AppToast.showError(context, e.message);
    } catch (e) {
      AppLog.d('[OTP] Resend error: $e');
      if (mounted)
        AppToast.showError(context, 'Could not resend OTP. Try again.');
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  String _formatCountdown(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppAppBar(
        title: 'Verify Phone',
        style: AppAppBarStyle.white,
      ),
      children: [
            Center(
              child: Column(
                children: [
                  const AppImage(AppIcon.logo2, height: 60),
                  AppSpaces.v8,
                  const AppSubText(
                    "No Stories. Just Delivery.",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            AppSpaces.v48,

            const AppHeader('Verify Phone'),
            AppSpaces.v8,
            AppSubText(
              'Enter the 6-digit code we sent to your '
              '${widget.channel == 'email' ? 'email' : 'phone'} '
              '(${widget.sentTo})',
              fontSize: 16,
            ),
            AppSpaces.v32,

            Center(
              child: AppOtpField(
                controller: _pinController,
                focusNode: _focusNode,
                onCompleted: (pin) => _verifyOtp(),
              ),
            ),

            if (_otpError != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Center(
                  child: AppText(
                    _otpError!,
                    color: AppColors.errorRed,
                    fontSize: 13,
                  ),
                ),
              ),

            AppSpaces.v32,

            CustomButton(
              text: 'Verify & Continue',
              backgroundColor: AppColors.primaryOrange,
              textColor: AppColors.white,
              isLoading: _isLoading,
              onPressed: _isLoading ? () {} : _verifyOtp,
            ),

            AppSpaces.v24,

            Center(
              child: _resendCountdown > 0
                  ? AppSubText(
                      'Resend code in ${_formatCountdown(_resendCountdown)}',
                      fontSize: 14,
                    )
                  : GestureDetector(
                      onTap: _isResending ? null : _resendOtp,
                      child: _isResending
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primaryOrange,
                              ),
                            )
                          : const AppText(
                              "Resend Code",
                              color: AppColors.primaryOrange,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                    ),
            ),

            AppSpaces.v16,

            Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const AppText(
                  "Change Phone Number",
                  color: AppColors.slate500,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
      ],
    );
  }
}
