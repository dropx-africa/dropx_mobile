import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/constants/app_icons.dart';
import 'package:dropx_mobile/src/common_widgets/custom_button.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/app_spacers.dart';
import 'package:dropx_mobile/src/common_widgets/app_image.dart';
import 'package:dropx_mobile/src/common_widgets/app_otp_field.dart';
import 'package:dropx_mobile/src/common_widgets/app_toast.dart';
import 'package:dropx_mobile/src/route/page.dart';
import 'package:dropx_mobile/src/utils/app_navigator.dart';
import 'package:dropx_mobile/src/core/network/api_exceptions.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/otp_verify_dto.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/otp_resend_dto.dart';
import 'package:dropx_mobile/src/features/auth/providers/auth_providers.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String otpChallengeId;
  final String? nextResendAt;
  final int? attemptsRemaining;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
    required this.otpChallengeId,
    this.nextResendAt,
    this.attemptsRemaining,
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
  late int _attemptsRemaining;

  // Resend countdown
  Timer? _resendTimer;
  int _resendCountdown = 0;

  @override
  void initState() {
    super.initState();
    _otpChallengeId = widget.otpChallengeId;
    _attemptsRemaining = widget.attemptsRemaining ?? 5;
    _startResendCountdown(widget.nextResendAt);
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startResendCountdown(String? nextResendAt) {
    _resendTimer?.cancel();

    if (nextResendAt == null) {
      setState(() => _resendCountdown = 60); // fallback 60s
    } else {
      try {
        final nextResend = DateTime.parse(nextResendAt);
        final diff = nextResend.difference(DateTime.now().toUtc()).inSeconds;
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

      if (kDebugMode) {
        print('[OTP] Verifying: ${dto.toJson()}');
      }

      final response = await ref.read(authRepositoryProvider).verifyOtp(dto);

      if (kDebugMode) {
        print('[OTP] Verified — userId: ${response.userId}');
      }

      final profileResponse = await ref
          .read(authRepositoryProvider)
          .getProfile();

    
   

      if (mounted) {
        AppToast.showSuccess(context, 'Phone verified successfully!');
        AppNavigator.pushReplacement(context, AppRoute.manualLocation);
      }
    } on ApiException catch (e) {
      if (kDebugMode) print('[OTP] ApiException: ${e.message}');
      if (mounted) {
        setState(() => _otpError = e.message);
      }
    } catch (e) {
      if (kDebugMode) print('[OTP] Unexpected error: $e');
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

      if (kDebugMode) {
        print('[OTP] Resending: ${dto.toJson()}');
      }

      final challenge = await ref.read(authRepositoryProvider).resendOtp(dto);

      _otpChallengeId = challenge.otpChallengeId;
      _attemptsRemaining = challenge.attemptsRemaining;

      _pinController.clear();
      _startResendCountdown(challenge.nextResendAt);

      if (mounted) {
        AppToast.showSuccess(context, 'OTP resent successfully!');
        setState(() => _otpError = null);
      }
    } on ApiException catch (e) {
      if (kDebugMode) print('[OTP] Resend ApiException: ${e.message}');
      if (mounted) AppToast.showError(context, e.message);
    } catch (e) {
      if (kDebugMode) print('[OTP] Resend error: $e');
      if (mounted) {
        AppToast.showError(context, 'Could not resend OTP. Try again.');
      }
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
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: AppColors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo
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
              'Enter the 6-digit code we sent to ${widget.phoneNumber}',
              fontSize: 16,
            ),
            AppSpaces.v32,

            // OTP Input
            Center(
              child: AppOtpField(
                controller: _pinController,
                focusNode: _focusNode,
                onCompleted: (pin) => _verifyOtp(),
              ),
            ),

            // Validation error
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

            // Attempts remaining
            if (_attemptsRemaining < 5)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Center(
                  child: AppSubText(
                    '$_attemptsRemaining attempts remaining',
                    fontSize: 12,
                  ),
                ),
              ),

            AppSpaces.v32,

            // Verify Button
            CustomButton(
              text: 'Verify & Continue',
              backgroundColor: AppColors.primaryOrange,
              textColor: AppColors.white,
              isLoading: _isLoading,
              onPressed: _isLoading ? () {} : _verifyOtp,
            ),

            AppSpaces.v24,

            // Resend OTP
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

            // Change Phone Number
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
        ),
      ),
    );
  }
}
