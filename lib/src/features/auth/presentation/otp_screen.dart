import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/constants/app_icons.dart';
import 'package:dropx_mobile/src/common_widgets/custom_button.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/app_spacers.dart';
import 'package:dropx_mobile/src/common_widgets/app_image.dart';
import 'package:dropx_mobile/src/common_widgets/app_otp_field.dart';
import 'package:dropx_mobile/src/route/page.dart';
import 'package:dropx_mobile/src/core/providers/core_providers.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phoneNumber;

  const OtpScreen({super.key, required this.phoneNumber});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _otpError;
  bool _isLoading = false;

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _verifyAndLogin() async {
    final pin = _pinController.text.trim();

    // Validate OTP is exactly 4 digits
    if (pin.length != 4 || !RegExp(r'^\d{4}$').hasMatch(pin)) {
      setState(() {
        _otpError = 'Please enter a valid 4-digit code';
      });
      return;
    }
    setState(() {
      _otpError = null;
      _isLoading = true;
    });

    try {
      // Persist login state
      await ref.read(sessionServiceProvider).saveLogin();

      if (mounted) {
        Navigator.pushNamed(
          context,
          AppRoute.manualLocation,
          arguments: {'isGuest': false},
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
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
              'Enter the code we sent to ${widget.phoneNumber}',
              fontSize: 16,
            ),
            AppSpaces.v32,

            // Pinput
            AppOtpField(
              controller: _pinController,
              focusNode: _focusNode,
              onCompleted: (pin) {
                // Auto-submit when 4 digits entered
                _verifyAndLogin();
              },
            ),

            // Validation error
            if (_otpError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: AppText(
                  _otpError!,
                  color: AppColors.errorRed,
                  fontSize: 12,
                ),
              ),

            AppSpaces.v32,

            // Verify Button
            CustomButton(
              text: 'Verify & Login',
              backgroundColor: AppColors.primaryOrange,
              textColor: AppColors.white,
              isLoading: _isLoading,
              onPressed: () => _verifyAndLogin(),
            ),

            AppSpaces.v24,
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
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
