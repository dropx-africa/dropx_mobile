import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/features/home/data/feed_item.dart';
import 'package:dropx_mobile/src/route/page.dart';
import 'package:dropx_mobile/src/utils/app_navigator.dart';

/// A card that displays a [FeedItem] from the /home/feed API.
/// Shows distance, rating, ETA, delivery fee, and open/closed badge.
class FeedVendorCard extends StatelessWidget {
  final FeedItem item;
  final double width;

  const FeedVendorCard({super.key, required this.item, this.width = 240});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppNavigator.push(
          context,
          AppRoute.vendorMenu,
          arguments: {'vendorId': item.vendorId},
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
            // Image placeholder with badges
            Stack(
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.slate200,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.store,
                      size: 40,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
                // Open / Closed badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: item.isOpen == true
                          ? Colors.green
                          : Colors.red.shade400,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: AppText(
                      item.isOpen == true ? 'Open' : 'Closed',
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Rating badge
                if (item.rating != null)
                  Positioned(
                    bottom: 8,
                    right: 8,
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
                            item.rating!.toStringAsFixed(1),
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
                  AppText(
                    item.displayName,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  if (item.categories != null &&
                      item.categories!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    AppText(
                      item.categories!.join(' • '),
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // ETA
                      if (item.etaMinutes != null) ...[
                        const Icon(
                          Icons.access_time_filled,
                          size: 13,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 3),
                        AppText(
                          '${item.etaMinutes} min',
                          fontSize: 11,
                          color: Colors.grey.shade700,
                        ),
                        const SizedBox(width: 8),
                      ],
                      // Distance
                      if (item.distanceKm != null) ...[
                        const Icon(
                          Icons.place_outlined,
                          size: 13,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 3),
                        AppText(
                          '${item.distanceKm!.toStringAsFixed(1)} km',
                          fontSize: 11,
                          color: Colors.grey.shade700,
                        ),
                        const SizedBox(width: 8),
                      ],
                      // Delivery fee
                      const Icon(
                        Icons.delivery_dining,
                        size: 13,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 3),
                      AppText(
                        '₦${item.deliveryFeeNaira.toInt()}',
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
}
