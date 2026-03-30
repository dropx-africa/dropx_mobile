import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/app_image.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';

/// A reusable horizontal vendor list card used across home feed and discover.
/// Shows a small image on the left with name, tags, distance, delivery fee,
/// and an open/closed badge on the right.
class VendorListCard extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final List<String>? tags;
  final double? distanceKm;
  final String deliveryFeeText;
  final bool? isOpen;
  final VoidCallback? onTap;

  const VendorListCard({
    super.key,
    required this.name,
    this.imageUrl,
    this.tags,
    this.distanceKm,
    required this.deliveryFeeText,
    this.isOpen,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: AppText(
                          name,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isOpen != null) ...[
                        const SizedBox(width: 8),
                        _buildOpenBadge(),
                      ],
                    ],
                  ),
                  if (tags != null && tags!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    AppSubText(
                      tags!.join(' • '),
                      fontSize: 12,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (distanceKm != null) ...[
                        const Icon(
                          Icons.place_outlined,
                          size: 13,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 3),
                        AppText(
                          '${distanceKm!.toStringAsFixed(1)} km',
                          fontSize: 11,
                          color: Colors.grey.shade700,
                        ),
                        const SizedBox(width: 8),
                      ],
                      const Icon(
                        Icons.delivery_dining,
                        size: 13,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 3),
                      AppText(
                        deliveryFeeText,
                        fontSize: 11,
                        color: Colors.grey.shade700,
                      ),
                    ],
                  ),
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
        width: 80,
        height: 80,
        borderRadius: BorderRadius.circular(8),
      );
    }
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.slate200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Icon(Icons.store, size: 32, color: Colors.grey.shade400),
      ),
    );
  }

  Widget _buildOpenBadge() {
    final open = isOpen == true;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: open ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: open ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          AppText(
            open ? 'Open' : 'Closed',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: open ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }
}
