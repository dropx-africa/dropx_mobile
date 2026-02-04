import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/features/home/widgets/vendor_card.dart';
import 'package:dropx_mobile/src/features/home/data/mock_vendors.dart';

class FeaturedSection extends StatelessWidget {
  final bool isGuest;

  const FeaturedSection({super.key, this.isGuest = false});

  @override
  Widget build(BuildContext context) {
    // Filter featured vendors
    final featuredVendors = mockVendors.where((v) => v.isFeatured).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText(
                'Featured Food',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
  }
}
