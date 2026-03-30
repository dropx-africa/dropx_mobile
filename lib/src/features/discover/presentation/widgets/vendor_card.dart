import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/common_widgets/vendor_list_card.dart';
import 'package:dropx_mobile/src/models/vendor.dart';

class VendorCard extends StatelessWidget {
  final Vendor vendor;
  final VoidCallback? onTap;

  const VendorCard({
    super.key,
    required this.vendor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final feeText = vendor.deliveryFeeKobo != null
        ? '₦${vendor.deliveryFeeNaira.toInt()}'
        : '₦${(vendor.deliveryFee ?? 0).toInt()}';

    return VendorListCard(
      name: vendor.name,
      imageUrl: vendor.imageUrl ?? vendor.logoUrl,
      tags: vendor.tags,
      distanceKm: vendor.distanceKm,
      deliveryFeeText: feeText,
      isOpen: vendor.isOpen,
      onTap: onTap,
    );
  }
}
