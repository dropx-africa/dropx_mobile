import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';

class AppToast {
  static void showSuccess(BuildContext context, String message) {
    _showToast(context, message, AppColors.secondaryGreen, Icons.check_circle);
  }

  static void showError(BuildContext context, String message) {
    _showToast(context, message, AppColors.errorRed, Icons.error);
  }

  static void _showToast(
    BuildContext context,
    String message,
    Color backgroundColor,
    IconData icon,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: AppColors.white),
            const SizedBox(width: 12),
            Expanded(
              child: AppText(message, color: AppColors.white, fontSize: 14),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
