import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';

/// A reusable loading widget displayed while waiting for API responses.
///
/// Shows a centered spinner with an optional message. Use this across all
/// screens that fetch data from the backend.
class AppLoadingWidget extends StatelessWidget {
  final String? message;
  final Color? color;

  const AppLoadingWidget({super.key, this.message, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: color ?? AppColors.primaryOrange,
            strokeWidth: 3,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
