import 'package:dropx_mobile/src/common_widgets/app_loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/features/vendor/providers/vendor_providers.dart';
import 'package:dropx_mobile/src/core/providers/core_providers.dart';
import 'package:dropx_mobile/src/models/vendor_category.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/features/home/widgets/vendor_card.dart';

class FeaturedSection extends ConsumerWidget {
  final VendorCategory category;

  const FeaturedSection({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendorsAsync = ref.watch(vendorsProvider(category));
    final session = ref.watch(sessionServiceProvider);
    final bool isGuest = session.isGuest;

    return vendorsAsync.when(
      loading: () =>
          const SizedBox(height: 250, child: Center(child: AppLoadingWidget())),
      error: (e, st) => const SizedBox.shrink(),
      data: (vendors) {
        final featuredVendors = vendors;

        if (featuredVendors.isEmpty) return const SizedBox.shrink();

        String title;
        switch (category) {
          case VendorCategory.parcel:
            title = 'Top Logistics Partners';
            break;
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
                    onPressed: () {},
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
              height: 250, // Adjusted height for new card
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: featuredVendors.length,
                itemBuilder: (context, index) {
                  return VendorCard(
                    vendor: featuredVendors[index],
                    isGuest: isGuest,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
