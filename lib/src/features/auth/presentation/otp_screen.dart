import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/constants/app_icons.dart';
import 'package:dropx_mobile/src/common_widgets/custom_button.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/app_spacers.dart';
import 'package:dropx_mobile/src/common_widgets/app_image.dart';
import 'package:dropx_mobile/src/common_widgets/app_otp_field.dart';
import 'package:dropx_mobile/src/route/page.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
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
            // Matches LoginScreen Logo placement
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
                // Determine next step based on needs, typically navigate or auto-submit
              },
            ),

            AppSpaces.v32,

            // Verify Button
            CustomButton(
              text: 'Verify & Login',
              backgroundColor: AppColors.primaryOrange,
              textColor: AppColors.white,
              onPressed: () {
                // Navigate directly to Manual Location (system will request permission)
                Navigator.pushNamed(
                  context,
                  AppRoute.manualLocation,
                  arguments: {'isGuest': false},
                );
              },
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
