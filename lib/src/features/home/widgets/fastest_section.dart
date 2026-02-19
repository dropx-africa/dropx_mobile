import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/features/home/widgets/vendor_card.dart';
import 'package:dropx_mobile/src/features/home/data/mock_vendors.dart';

class FastestSection extends StatelessWidget {
  final bool isGuest;
  final String category;

  const FastestSection({
    super.key,
    this.isGuest = false,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    // Filter fastest vendors by category
    final fastestVendors = mockVendors
        .where((v) => v.isFastest && v.category == category)
        .toList();

    if (fastestVendors.isEmpty) {
      return const SizedBox.shrink();
    }

    String title;
    switch (category) {
      case 'Parcel':
        title = 'Express Logistics';
        break;
      case 'Pharmacy':
        title = 'Quick Meds';
        break;
      case 'Retail':
        title = 'Quick Retail';
        break;
      default:
        title = 'Fastest Food';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.bolt, color: AppColors.primaryOrange, size: 20),
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
  }
}
