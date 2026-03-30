import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/common_widgets/vendor_grid_card.dart';
import 'package:dropx_mobile/src/features/home/data/feed_item.dart';
import 'package:dropx_mobile/src/route/page.dart';
import 'package:dropx_mobile/src/utils/app_navigator.dart';

/// Wraps [FeedItem] data into a [VendorGridCard].
class FeedVendorCard extends StatelessWidget {
  final FeedItem item;

  /// Fixed width for horizontal-scroll lists; leave null for grid/full-width use.
  final double? width;

  const FeedVendorCard({super.key, required this.item, this.width});

  @override
  Widget build(BuildContext context) {
    return VendorGridCard(
      name: item.displayName,
      tags: item.categories,
      distanceKm: item.distanceKm,
      etaMinutes: item.etaMinutes,
      deliveryFeeText: '₦${item.deliveryFeeNaira.toInt()}',
      isOpen: item.isOpen,
      width: width,
      onTap: () => AppNavigator.push(
        context,
        AppRoute.vendorMenu,
        arguments: {'vendorId': item.vendorId},
      ),
    );
  }
}
