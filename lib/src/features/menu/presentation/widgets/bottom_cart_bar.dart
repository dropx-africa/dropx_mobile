import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/core/utils/formatters.dart';
import 'package:dropx_mobile/src/route/page.dart';

class BottomCartBar extends StatelessWidget {
  final int itemCount;
  final double totalPrice;
  final bool isGuest;

  const BottomCartBar({
    super.key,
    required this.itemCount,
    required this.totalPrice,
    this.isGuest = false,
  });

  @override
  Widget build(BuildContext context) {
    if (itemCount == 0) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoute.cart,
          arguments: {'isGuest': isGuest},
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primaryOrange,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    color: AppColors.primaryOrange,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                AppText(
                  itemCount == 1 ? "1 Order item" : "$itemCount Order items",
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  decoration: TextDecoration.none,
                ),
              ],
            ),
            AppText(
              Formatters.formatNaira(totalPrice),
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              decoration: TextDecoration.none,
            ),
          ],
        ),
      ),
    );
  }
}
