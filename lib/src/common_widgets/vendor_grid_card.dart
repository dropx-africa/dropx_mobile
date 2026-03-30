import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/app_image.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';

/// A vertical vendor card used on the home screen (featured/fastest sections)
/// and the discover screen for visual consistency.
///
/// Pass [width] for use in a horizontal-scroll list. Leave null for full-width
/// or grid use.
class VendorGridCard extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final List<String>? tags;
  final double? distanceKm;
  final int? etaMinutes;
  final String deliveryFeeText;
  final bool? isOpen;
  final double? rating;
  final VoidCallback? onTap;

  /// Fixed width for horizontal-scroll lists; leave null to fill available space.
  final double? width;

  const VendorGridCard({
    super.key,
    required this.name,
    this.imageUrl,
    this.tags,
    this.distanceKm,
    this.etaMinutes,
    required this.deliveryFeeText,
    this.isOpen,
    this.rating,
    this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
              child: Stack(
                children: [
                  _buildImage(),
                  // Open/closed badge — top right
                  if (isOpen != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _buildOpenBadge(),
                    ),
                ],
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    name,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (tags != null && tags!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    AppSubText(
                      tags!.join(' • '),
                      fontSize: 11,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  _buildMetaRow(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return AppImage(
        imageUrl!,
        width: width ?? double.infinity,
        height: 120,
        fit: BoxFit.cover,
      );
    }
    return Container(
      width: width ?? double.infinity,
      height: 120,
      color: AppColors.slate200,
      child: Center(
        child: Icon(Icons.store, size: 36, color: Colors.grey.shade400),
      ),
    );
  }

  Widget _buildOpenBadge() {
    final open = isOpen == true;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: open ? Colors.green.shade600 : Colors.red.shade600,
        borderRadius: BorderRadius.circular(8),
      ),
      child: AppText(
        open ? 'Open' : 'Closed',
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildMetaRow() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        if (distanceKm != null)
          _metaChip(Icons.place_outlined, '${distanceKm!.toStringAsFixed(1)} km'),
        if (etaMinutes != null)
          _metaChip(Icons.access_time, '$etaMinutes min'),
        _metaChip(Icons.delivery_dining, deliveryFeeText),
      ],
    );
  }

  Widget _metaChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: Colors.grey.shade500),
        const SizedBox(width: 2),
        AppText(label, fontSize: 11, color: Colors.grey.shade600),
      ],
    );
  }
}
