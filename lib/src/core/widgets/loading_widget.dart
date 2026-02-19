import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';

/// A reusable loading widget that can be used as a full-screen overlay
/// or inline within a list/column.
class AppLoadingWidget extends StatelessWidget {
  final String? message;
  final bool fullScreen;

  const AppLoadingWidget({super.key, this.message, this.fullScreen = true});

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(
          color: AppColors.primaryOrange,
          strokeWidth: 3,
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ],
    );

    if (fullScreen) {
      return Center(child: content);
    }
    return Padding(padding: const EdgeInsets.all(24.0), child: content);
  }
}
