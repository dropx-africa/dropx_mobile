import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/core/utils/formatters.dart';

/// Explains why a delivery costs more (or the standard amount) because of
/// how far the vendor is from the customer's delivery address.
///
/// Used two ways:
/// - Inline, with real numbers (eta/distance/fee) once an order estimate is
///   available — e.g. on the cart screen.
/// - As a lightweight preview via [DeliveryZoneNotice.showPreviewModal],
///   before any pricing estimate exists yet — e.g. right when a customer
///   opens a cross-zone vendor's menu, so the higher fee is never a surprise
///   later at checkout.
class DeliveryZoneNotice extends StatelessWidget {
  final bool isCrossZone;
  final int? etaMinutes;
  final double? distanceKm;
  final double? deliveryFeeNaira;

  /// Shows the "by placing this order..." acceptance line — only relevant
  /// once real pricing exists (checkout), not in the early preview.
  final bool showAcceptanceNotice;

  const DeliveryZoneNotice({
    super.key,
    required this.isCrossZone,
    this.etaMinutes,
    this.distanceKm,
    this.deliveryFeeNaira,
    this.showAcceptanceNotice = false,
  });

  /// Shows a one-off, dismissible modal warning that this vendor is
  /// cross-zone — used before the customer has added anything to cart, so
  /// no real distance/fee numbers exist yet.
  static Future<void> showPreviewModal(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const DeliveryZoneNotice(isCrossZone: true),
              const SizedBox(height: 16),
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const AppText(
                    'Got it',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _hasNumbers =>
      etaMinutes != null || distanceKm != null || deliveryFeeNaira != null;

  String get _subtitle {
    if (isCrossZone) {
      if (distanceKm != null) {
        return 'This vendor is about ${distanceKm!.toStringAsFixed(1)} km '
            'from your delivery address, so the delivery fee is higher to '
            'cover the extra distance.';
      }
      return "This vendor is outside your immediate delivery zone, so "
          "delivery costs more than nearby vendors. You'll see the exact "
          "delivery fee before you pay.";
    }
    return 'This vendor is close to your delivery address, so the '
        'standard delivery fee applies.';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCrossZone
            ? AppColors.primaryOrange.withValues(alpha: 0.06)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCrossZone
              ? AppColors.primaryOrange.withValues(alpha: 0.4)
              : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isCrossZone
                      ? AppColors.primaryOrange.withValues(alpha: 0.12)
                      : Colors.green.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCrossZone ? Icons.alt_route_rounded : Icons.near_me_rounded,
                  size: 18,
                  color: isCrossZone ? AppColors.primaryOrange : Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      isCrossZone ? 'Longer delivery distance' : 'Nearby delivery',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    const SizedBox(height: 2),
                    AppText(_subtitle, fontSize: 12, color: Colors.grey.shade600),
                  ],
                ),
              ),
            ],
          ),
          if (_hasNumbers) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (etaMinutes != null)
                  _ZonePill(
                    icon: Icons.access_time_rounded,
                    label: 'ETA $etaMinutes mins',
                  ),
                if (distanceKm != null)
                  _ZonePill(
                    icon: Icons.social_distance_rounded,
                    label: '${distanceKm!.toStringAsFixed(1)} km away',
                  ),
                if (deliveryFeeNaira != null)
                  _ZonePill(
                    icon: Icons.delivery_dining_rounded,
                    label: 'Delivery ${Formatters.formatNaira(deliveryFeeNaira!)}',
                  ),
              ],
            ),
          ],
          if (showAcceptanceNotice) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const AppText(
                'By placing this order, you agree to the delivery fee shown above.',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.darkBackground,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ZonePill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ZonePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.grey.shade700),
          const SizedBox(width: 5),
          AppText(label, fontSize: 11, color: Colors.grey.shade700),
        ],
      ),
    );
  }
}
