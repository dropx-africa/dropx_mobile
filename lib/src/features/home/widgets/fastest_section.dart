import 'package:dropx_mobile/src/common_widgets/app_loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/core/providers/core_providers.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/features/home/data/feed_item.dart';
import 'package:dropx_mobile/src/features/home/widgets/feed_vendor_card.dart';
import 'package:dropx_mobile/src/features/home/providers/home_feed_providers.dart';
import 'package:dropx_mobile/src/models/vendor_category.dart';
import 'package:dropx_mobile/src/route/page.dart';
import 'package:dropx_mobile/src/utils/app_navigator.dart';

class FastestSection extends ConsumerWidget {
  final VendorCategory category;

  const FastestSection({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionServiceProvider);
    final feedParams = FeedParams(
      vertical: category.apiValue,
      lat: session.savedLat,
      lng: session.savedLng,
      maxEtaMinutes: 35,
      limit: 20,
    );
    final feedAsync = ref.watch(homeFeedProvider(feedParams));

    return feedAsync.when(
      loading: () =>
          const SizedBox(height: 250, child: Center(child: AppLoading())),
      error: (e, st) => const SizedBox.shrink(),
      data: (feedData) {
        // Filter to only vendors with a valid eta, then sort fastest first.
        final fastest = _buildFastestList(feedData.items);

        // If no vendors have eta at all, hide this section entirely.
        if (fastest.isEmpty) return const SizedBox.shrink();

        // Choose title: if most items have eta use "Fastest X", else "Nearby X".
        final bool mostHaveEta =
            fastest.length >= (feedData.items.length * 0.5);
        final String title = _title(category, mostHaveEta);
        final String seeAllRoute = category == VendorCategory.food
            ? AppRoute.fastestFood
            : AppRoute.fastestRetail;

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
                    onPressed: () =>
                        AppNavigator.push(context, seeAllRoute),
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
                itemCount: fastest.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: FeedVendorCard(item: fastest[index], width: 180),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<FeedItem> _buildFastestList(List<FeedItem> items) {
    final filtered = items
        .where((v) => v.etaMinutes != null && v.etaMinutes! > 0)
        .toList()
      ..sort((a, b) {
        final etaCompare = a.etaMinutes!.compareTo(b.etaMinutes!);
        if (etaCompare != 0) return etaCompare;
        final aDist = a.distanceKm ?? double.infinity;
        final bDist = b.distanceKm ?? double.infinity;
        return aDist.compareTo(bDist);
      });
    return filtered;
  }

  String _title(VendorCategory category, bool mostHaveEta) {
    switch (category) {
      case VendorCategory.food:
        return mostHaveEta ? 'Fastest Food' : 'Nearby Food';
      case VendorCategory.retail:
        return mostHaveEta ? 'Quick Stores' : 'Nearby Stores';
      case VendorCategory.pharmacy:
        return mostHaveEta ? 'Quick Meds' : 'Nearby Pharmacies';
      case VendorCategory.parcel:
      case VendorCategory.other:
        return 'Nearby Vendors';
    }
  }
}
