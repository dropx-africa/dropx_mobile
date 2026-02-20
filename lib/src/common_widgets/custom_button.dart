import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final Widget? icon;
  final bool isLoading;
  final double? width;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.icon,
    this.isLoading = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.primaryOrange;
    final txtColor = textColor ?? AppColors.white;

    return SizedBox(
      width: width ?? double.infinity,
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(30),
        child: InkResponse(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(30),
          highlightShape: BoxShape.rectangle,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: borderColor != null
                  ? Border.all(color: borderColor!)
                  : null,
            ),
            child: isLoading
                ? Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: txtColor,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[icon!, const SizedBox(width: 8)],
                      Text(
                        text,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: txtColor,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
