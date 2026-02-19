import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/common_widgets/custom_button.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/app_spacers.dart';
import 'package:dropx_mobile/src/route/page.dart';

class SignUpToOrderSheet extends StatelessWidget {
  const SignUpToOrderSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryOrange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.login_rounded,
              color: AppColors.primaryOrange,
              size: 32,
            ),
          ),
          AppSpaces.v24,

          // Title
          const AppHeader("Sign Up to Order", textAlign: TextAlign.center),
          AppSpaces.v8,

          // Subtitle
          const AppSubText(
            "Create an account to start ordering from 3+ vendors in Yaba",
            textAlign: TextAlign.center,
            fontSize: 16,
          ),
          AppSpaces.v32,

          // Sign Up Button
          CustomButton(
            text: 'Sign Up Now',
            onPressed: () {
              Navigator.pop(context); // Close sheet
              Navigator.pushNamed(context, AppRoute.login);
            },
            backgroundColor: AppColors.primaryOrange,
            textColor: Colors.white,
          ),
          AppSpaces.v16,

          // Continue Browsing
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const AppText(
              "Continue Browsing",
              color: AppColors.slate500,
              fontWeight: FontWeight.w600,
            ),
          ),
          AppSpaces.v16,
        ],
      ),
    );
  }
}
