import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';

/// A reusable empty state widget for displaying when there are no items.
///
/// Shows an icon, title, and message to inform the user about the empty state.
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final double iconSize;
  final Color? iconColor;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.iconSize = 60,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: iconSize, color: iconColor ?? AppColors.slate400),
          const SizedBox(height: 16),
          AppText(
            title,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.slate500,
          ),
          const SizedBox(height: 8),
          AppText(
            message,
            fontSize: 14,
            color: AppColors.slate400,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
