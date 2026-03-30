import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/common_widgets/vendor_grid_card.dart';
import 'package:dropx_mobile/src/models/vendor.dart';
import 'package:dropx_mobile/src/utils/currency_utils.dart';

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
        ? CurrencyUtils.formatKoboAsNaira(vendor.deliveryFeeKobo)
        : '₦${(vendor.deliveryFee ?? 0).toInt()}';

    return VendorGridCard(
      name: vendor.name,
      imageUrl: vendor.imageUrl ?? vendor.logoUrl ?? vendor.coverImageUrl,
      tags: vendor.tags,
      distanceKm: vendor.distanceKm,
      etaMinutes: vendor.etaMinutes,
      deliveryFeeText: feeText,
      isOpen: vendor.isOpen,
      rating: vendor.rating,
      onTap: onTap,
    );
  }
}
