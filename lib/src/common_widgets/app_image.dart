import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';

class AppImage extends StatelessWidget {
  final String imagePath;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final Color? color;

  const AppImage(
    this.imagePath, {
    super.key,
    this.height,
    this.width,
    this.fit,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        height: height,
        width: width,
        fit: fit,
        color: color,
        errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
      );
    }
    return Image.asset(
      imagePath,
      height: height,
      width: width,
      fit: fit ?? BoxFit.contain, // Default for logos/icons
      color: color,
      errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      height: height,
      width: width,
      color: Colors.grey.shade200,
      child: const Icon(Icons.image_not_supported, color: AppColors.slate500),
    );
  }
}
