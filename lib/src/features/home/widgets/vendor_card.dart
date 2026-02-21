import 'package:dropx_mobile/src/constants/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/models/vendor.dart';
import 'package:dropx_mobile/src/route/page.dart';
import 'package:dropx_mobile/src/utils/app_navigator.dart';

class VendorCard extends StatelessWidget {
  final Vendor vendor;
  final double width;
  final bool isGuest;

  const VendorCard({
    super.key,
    required this.vendor,
    this.width = 240,
    this.isGuest = false,
  });

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print(
        'VendorCard build: ${vendor.name}, id: ${vendor.id}, '
        'rating: ${vendor.rating}, deliveryFee: ${vendor.deliveryFee}',
      );
    }
    return GestureDetector(
      onTap: () {
        AppNavigator.push(
          context,
          AppRoute.vendorMenu,
          arguments: {'vendorId': vendor.id},
        );
      },
      child: Container(
        width: width,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              children: [
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    image: DecorationImage(
                      image: AssetImage(vendor.imageUrl ?? AppIcon.foodJollof),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (vendor.isFeatured ||
                    vendor.isFastest ||
                    vendor.accuracyBadge != null)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: AppText(
                        vendor.accuracyBadge ??
                            (vendor.isFastest ? "Fastest" : "Featured"),
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          size: 12,
                          color: AppColors.primaryOrange,
                        ),
                        const SizedBox(width: 4),
                        AppText(
                          '${vendor.rating ?? 0} (${vendor.ratingCount ?? 0}+)',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Info Section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: AppText(
                          vendor.name,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  AppSubText(
                    (vendor.tags ?? ['rice']).join(" • "),
                    fontSize: 12,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_filled,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      AppSubText(vendor.deliveryTime ?? '9:00AM', fontSize: 12),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.delivery_dining,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      AppSubText(
                        "₦${(vendor.deliveryFee ?? 0).toInt()}",
                        fontSize: 12,
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
}
