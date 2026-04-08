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
    final feedParams = FeedParams(
      vertical: category.name,
      lat: session.savedLat,
      lng: session.savedLng,
    );
    final feedAsync = ref.watch(homeFeedProvider(feedParams));

    return feedAsync.when(
      loading: () =>
          const SizedBox(height: 250, child: Center(child: AppLoading())),
      error: (e, st) => const SizedBox.shrink(),
      data: (feedData) {
        final items = feedData.items;

        String title;
        switch (category) {
          case VendorCategory.pharmacy:
            title = 'Featured Pharmacies';
            break;
          case VendorCategory.retail:
            title = 'Top Stores';
            break;
          case VendorCategory.food:
            title = 'Featured Food';
            break;
          default:
            title = 'Featured Vendors';
        }

        if (items.isEmpty) {
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
              height: 220,
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
    String message = "No vendors available right now.";
    if (category == VendorCategory.pharmacy) {
      message = "No pharmacies found near your location.";
    } else if (category == VendorCategory.retail) {
      message = "No retail stores found near you.";
    }

    return AppEmptyState(
      icon: Icons.storefront_outlined,
      title: "Coming Soon",
      message: message,
    );
  }
}
