import 'package:dropx_mobile/src/common_widgets/app_loading_widget.dart';
import 'package:dropx_mobile/src/core/providers/core_providers.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/features/vendor/providers/vendor_providers.dart';
import 'package:dropx_mobile/src/models/vendor_category.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/features/home/widgets/vendor_card.dart';

class FastestSection extends ConsumerWidget {
  final VendorCategory category;

  const FastestSection({super.key, required this.category});

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
        final fastestVendors = vendors;
        if (fastestVendors.isEmpty) return const SizedBox.shrink();

        if (fastestVendors.isEmpty) {
          return const SizedBox.shrink();
        }

        String title;
        switch (category) {
          case VendorCategory.parcel:
            title = 'Express Logistics';
            break;
          case VendorCategory.pharmacy:
            title = 'Quick Meds';
            break;
          case VendorCategory.retail:
            title = 'Quick Retail';
            break;
          case VendorCategory.food:
            title = 'Fastest Food';
            break;
          default:
            title = 'Fastest Vendors';
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(
                    Icons.bolt,
                    color: AppColors.primaryOrange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  AppText(title, fontSize: 18, fontWeight: FontWeight.bold),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 250, // Matches VendorCard height requirements
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: fastestVendors.length,
                itemBuilder: (context, index) {
                  return VendorCard(
                    vendor: fastestVendors[index],
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
