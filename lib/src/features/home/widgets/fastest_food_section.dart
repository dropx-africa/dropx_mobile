import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/features/home/widgets/vendor_card.dart';
import 'package:dropx_mobile/src/features/home/data/mock_vendors.dart';

class FastestFoodSection extends StatelessWidget {
  const FastestFoodSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Filter fastest vendors or just mock it for now
    final fastestVendors = mockVendors.where((v) => v.isFastest).toList();
    // Add others if list is empty to show something
    if (fastestVendors.isEmpty) {
      fastestVendors.addAll(mockVendors.take(2));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText(
                'Fastest Delivery',
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
          height: 250,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: fastestVendors.length,
            itemBuilder: (context, index) {
              return VendorCard(vendor: fastestVendors[index]);
            },
          ),
        ),
      ],
    );
  }
}
