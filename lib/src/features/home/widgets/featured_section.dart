import 'package:dropx_mobile/src/common_widgets/app_loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/core/providers/core_providers.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/app_empty_state.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/features/home/widgets/feed_vendor_card.dart';
import 'package:dropx_mobile/src/features/home/providers/home_feed_providers.dart';
import 'package:dropx_mobile/src/models/vendor_category.dart';
import 'package:dropx_mobile/src/route/page.dart';
import 'package:dropx_mobile/src/utils/app_navigator.dart';

class FeaturedSection extends ConsumerWidget {
  final VendorCategory category;

  const FeaturedSection({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionServiceProvider);
    // Same params as FastestSection's fetch (limit 20, no eta cap) so
    // Riverpod dedupes both sections onto a single /home/feed request
    // instead of firing it twice for the same vertical every time the
    // home tab loads.
    final feedParams = FeedParams(
      vertical: category.apiValue,
      lat: session.savedLat,
      lng: session.savedLng,
      limit: 20,
    );
    final feedAsync = ref.watch(homeFeedProvider(feedParams));

    return feedAsync.when(
      loading: () =>
      const SizedBox(height: 250, child: Center(child: AppLoading())),
      error: (e, st) => const SizedBox.shrink(),
      data: (feedData) {
        final items = feedData.items.take(10).toList();

        String title;
        switch (category) {
          case VendorCategory.food:
            title = 'Featured Food';
            break;
          case VendorCategory.retail:
            title = 'Top Stores';
            break;
          case VendorCategory.pharmacy:
            title = 'Featured Pharmacies';
            break;
          case VendorCategory.parcel:
          case VendorCategory.other:
            title = 'Featured Vendors';
            break;
        }

        if (items.isEmpty) {
          // For food we hide the section silently when empty.
          // For retail we show a coming soon state.
          if (category == VendorCategory.food) {
            return const SizedBox.shrink();
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AppText(
                  title,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildEmptyState(category),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(title, fontSize: 18, fontWeight: FontWeight.bold),
                  TextButton(
                    onPressed: () {
                      if (category == VendorCategory.food) {
                        AppNavigator.push(context, AppRoute.featuredFood);
                      } else if (category == VendorCategory.retail) {
                        AppNavigator.push(context, AppRoute.featuredRetail);
                      }
                    },
                    child: const Text(
                      'See all',
                      style: TextStyle(color: AppColors.primaryOrange),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 240,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: FeedVendorCard(item: items[index], width: 180),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(VendorCategory category) {
    String message;
    switch (category) {
      case VendorCategory.retail:
        message = 'No stores near you right now.';
        break;
      case VendorCategory.pharmacy:
        message = 'No pharmacies found near your location.';
        break;
      case VendorCategory.food:
      case VendorCategory.parcel:
      case VendorCategory.other:
        message = 'No vendors available right now.';
        break;
    }
    return AppEmptyState(
      icon: Icons.storefront_outlined,
      title: 'Coming Soon',
      message: message,
    );
  }
}