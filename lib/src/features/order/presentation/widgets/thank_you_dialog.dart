import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/custom_button.dart';
import 'package:dropx_mobile/src/common_widgets/app_spacers.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/route/page.dart';

class ThankYouDialog extends StatelessWidget {
  const ThankYouDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Shareable Card
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.thumb_up,
                    color: AppColors.primaryOrange,
                    size: 48,
                  ),
                ),
                AppSpaces.v24,
                const AppText(
                  "Thank You!",
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  textAlign: TextAlign.center,
                ),
                AppSpaces.v8,
                const AppText(
                  "Your feedback helps us improve our service.",
                  textAlign: TextAlign.center,
                  color: Colors.grey,
                ),
                AppSpaces.v24,
                // Rating Summary Visualization (Mockup for screenshot)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.star,
                        color: AppColors.primaryOrange,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      AppText(
                        "5.0 Rating Submitted",
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppSpaces.v24,

          // Back to Home Button
          CustomButton(
            text: "Back to Home",
            backgroundColor: AppColors.primaryOrange, // Or white if preferred
            textColor: Colors.white,
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoute.dashboard,
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
