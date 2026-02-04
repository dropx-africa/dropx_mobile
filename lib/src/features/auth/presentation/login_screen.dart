import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/constants/app_icons.dart';
import 'package:dropx_mobile/src/common_widgets/custom_button.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/app_text_field.dart';
import 'package:dropx_mobile/src/common_widgets/app_spacers.dart';
import 'package:dropx_mobile/src/common_widgets/app_image.dart';
import 'package:dropx_mobile/src/route/page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _phoneNumber = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const SizedBox.shrink(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const AppHeader('Get Started'),
              AppSpaces.v8,
              const AppSubText(
                'Enter your phone number to login or sign up.',
                fontSize: 16,
              ),
              AppSpaces.v32,

              // Phone Number Input
              AppTextField(
                isPhone: true,
                onPhoneChanged: (phone) {
                  setState(() {
                    _phoneNumber = phone.completeNumber;
                  });
                },
              ),
              AppSpaces.v32,

              // Continue Button
              CustomButton(
                text: 'Continue',
                icon: const Icon(Icons.arrow_forward, color: AppColors.white),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pushNamed(
                      context,
                      AppRoute.otp,
                      arguments: {'phoneNumber': _phoneNumber},
                    );
                  }
                },
                backgroundColor: AppColors.darkBackground,
                textColor: AppColors.white,
              ),

              AppSpaces.v24,

              // Terms
              const Center(
                child: AppSubText(
                  "By continuing, you agree to our Terms & Privacy Policy.",
                  textAlign: TextAlign.center,
                  fontSize: 12,
                ),
              ),

              AppSpaces.v40,

              // Continue as Guest
              Center(
                child: TextButton(
                  onPressed: () {
                    // Navigate directly to manual location as guest
                    Navigator.pushNamed(
                      context,
                      AppRoute.manualLocation,
                      arguments: {'isGuest': true},
                    );
                  },
                  child: const AppText(
                    "Continue as Guest",
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
