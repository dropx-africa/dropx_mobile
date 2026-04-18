import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/features/parcel/data/dto/parcel_detail_response.dart';
import 'package:dropx_mobile/src/features/parcel/providers/parcel_providers.dart';
import 'package:dropx_mobile/src/route/page.dart';

Color _stateColor(String state) {
  switch (state) {
    case 'DELIVERED':
    case 'COMPLETED':
      return Colors.green;
    case 'CANCELLED':
      return Colors.red;
    case 'IN_TRANSIT':
    case 'PICKED_UP':
      return AppColors.primaryOrange;
    default:
      return Colors.blueGrey;
  }
}

String _stateLabel(String state) {
  const labels = {
    'PENDING_PAYMENT': 'Awaiting Payment',
    'PAYMENT_PENDING': 'Awaiting Payment',
    'REQUESTED': 'Pickup Requested',
    'ASSIGNED': 'Rider Assigned',
    'PICKED_UP': 'Picked Up',
    'IN_TRANSIT': 'In Transit',
    'DELIVERED': 'Delivered',
    'COMPLETED': 'Completed',
    'CANCELLED': 'Cancelled',
    'DRAFT': 'Draft',
  };
  return labels[state] ?? state.replaceAll('_', ' ');
}

IconData _stateIcon(String state) {
  switch (state) {
    case 'PENDING_PAYMENT':
    case 'PAYMENT_PENDING':
      return Icons.payment_outlined;
    case 'REQUESTED':
      return Icons.access_time_outlined;
    case 'ASSIGNED':
      return Icons.delivery_dining_outlined;
    case 'PICKED_UP':
      return Icons.inventory_2_outlined;
    case 'IN_TRANSIT':
      return Icons.local_shipping_outlined;
    case 'DELIVERED':
    case 'COMPLETED':
      return Icons.check_circle_outline;
    case 'CANCELLED':
      return Icons.cancel_outlined;
    default:
      return Icons.circle_outlined;
  }
}

class RecentParcelsSection extends ConsumerWidget {
  const RecentParcelsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parcelsAsync = ref.watch(parcelsProvider);

    return parcelsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          height: 100,
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (parcels) {
        if (parcels.isEmpty) return const SizedBox.shrink();

        final recent = parcels.take(5).toList();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppText(
                    'My Parcels',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, AppRoute.parcel),
                    child: AppText(
                      'Send New',
                      fontSize: 13,
                      color: AppColors.primaryOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: recent.length,
                  itemBuilder: (context, index) {
                    return _ParcelCard(parcel: recent[index]);
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

class _ParcelCard extends StatelessWidget {
  final ParcelDetail parcel;

  const _ParcelCard({required this.parcel});

  @override
  Widget build(BuildContext context) {
    final color = _stateColor(parcel.state);
    final label = _stateLabel(parcel.state);
    final icon = _stateIcon(parcel.state);
    final shortId = parcel.parcelId.length > 8
        ? parcel.parcelId.substring(0, 8)
        : parcel.parcelId;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoute.parcelTracking,
        arguments: {'parcelId': parcel.parcelId},
      ),
      child: Container(
        width: 190,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppText(
                    '#$shortId',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: AppText(
                label,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.chevron_right, size: 14, color: AppColors.slate400),
                AppText(
                  (parcel.state == 'DELIVERED' ||
                          parcel.state == 'COMPLETED' ||
                          parcel.state == 'CANCELLED')
                      ? 'View details'
                      : 'Tap to track',
                  fontSize: 11,
                  color: AppColors.slate400,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
