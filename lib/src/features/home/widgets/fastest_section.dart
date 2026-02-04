import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/features/home/widgets/vendor_card.dart';
import 'package:dropx_mobile/src/features/home/data/mock_vendors.dart';

class FastestSection extends StatelessWidget {
  final bool isGuest;

  const FastestSection({super.key, this.isGuest = false});

  @override
  Widget build(BuildContext context) {
    // Filter fastest vendors
    final fastestVendors = mockVendors.where((v) => v.isFastest).toList();
    // Fallback: If no dedicated "fastest" vendors, just show some vendors
    if (fastestVendors.isEmpty) {
      fastestVendors.addAll(mockVendors.take(2));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.bolt, color: AppColors.primaryOrange, size: 20),
              SizedBox(width: 8),
              AppText(
                'Fastest Food',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
