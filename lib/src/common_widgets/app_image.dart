import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';

/// A reusable image widget that handles both network and asset images.
///
/// Supports optional [borderRadius] for rounded corners, a loading placeholder,
/// and a graceful error fallback.
class AppImage extends StatelessWidget {
  final String imagePath;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final Color? color;
  final BorderRadius? borderRadius;

  const AppImage(
    this.imagePath, {
    super.key,
    this.height,
    this.width,
    this.fit,
    this.color,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final image = imagePath.startsWith('http')
        ? Image.network(
            imagePath,
            height: height,
            width: width,
            fit: fit ?? BoxFit.cover,
            color: color,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildLoadingPlaceholder();
            },
            errorBuilder: (context, error, stackTrace) =>
                _buildErrorPlaceholder(),
          )
        : Image.asset(
            imagePath,
            height: height,
            width: width,
            fit: fit ?? BoxFit.contain,
            color: color,
            errorBuilder: (context, error, stackTrace) =>
                _buildErrorPlaceholder(),
          );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      height: height,
      width: width,
      color: Colors.grey.shade100,
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.slate400,
          ),
        ),
      ),
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
