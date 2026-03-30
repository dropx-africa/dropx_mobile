import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/common_widgets/vendor_list_card.dart';
import 'package:dropx_mobile/src/features/home/data/feed_item.dart';
import 'package:dropx_mobile/src/route/page.dart';
import 'package:dropx_mobile/src/utils/app_navigator.dart';

/// A card that displays a [FeedItem] from the /home/feed API.
class FeedVendorCard extends StatelessWidget {
  final FeedItem item;

  const FeedVendorCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return VendorListCard(
      name: item.displayName,

      tags: item.categories,
      distanceKm: item.distanceKm,
      deliveryFeeText: '₦${item.deliveryFeeNaira.toInt()}',
      isOpen: item.isOpen,
      onTap: () => AppNavigator.push(
        context,
        AppRoute.vendorMenu,
        arguments: {'vendorId': item.vendorId},
      ),
    );
  }
}
