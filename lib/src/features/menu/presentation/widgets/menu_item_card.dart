import 'package:dropx_mobile/src/core/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/app_image.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/models/menu_item.dart';

import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/common_widgets/app_image.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/models/menu_item.dart';

class MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final int quantity;
  final VoidCallback? onAdd;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  const MenuItemCard({
    super.key,
    required this.item,
    this.quantity = 0,
    this.onAdd,
    this.onIncrement,
    this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    // Use canAddToCart which combines isAvailable + stock state
    final canAdd = item.canAddToCart;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildItemImage(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: AppText(
                            item.name,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        AppText(
                          Formatters.formatNaira(item.price),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Badges row — existing food badges + retail stock badges
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        // Existing food badges (popular, chef's pick, etc.)
                        if (item.badges != null && item.badges!.isNotEmpty)
                          ...item.badges!.map((badge) {
                            Color bgColor = Colors.purple.shade50;
                            Color textColor = Colors.purple;
                            if (badge.contains('ordered')) {
                              bgColor = Colors.red.shade50;
                              textColor = Colors.red;
                            }
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (badge.contains('ordered'))
                                    Icon(Icons.local_fire_department,
                                        size: 10, color: textColor),
                                  if (badge.contains('ordered'))
                                    const SizedBox(width: 4),
                                  if (badge.contains('Chef'))
                                    Icon(Icons.restaurant_menu,
                                        size: 10, color: textColor),
                                  if (badge.contains('Chef'))
                                    const SizedBox(width: 4),
                                  Text(
                                    badge,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),

                        // Retail: out of stock badge
                        if (item.isOutOfStock)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Out of stock',
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                        // Retail: low stock warning badge
                        if (!item.isOutOfStock && item.isLowStock)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.inventory_2_outlined,
                                    size: 10,
                                    color: Colors.orange.shade700),
                                const SizedBox(width: 4),
                                Text(
                                  (item.stockCount != null && item.stockCount! > 0)
                                      ? 'Only ${item.stockCount} left'
                                      : 'Low stock',
                                  style: TextStyle(
                                    color: Colors.orange.shade700,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 6),
                    AppSubText(
                      item.description ?? '',
                      fontSize: 12,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Prep time — food specific, won't show for retail items
                    // that don't have this field
                    if (item.prepTime != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined,
                              size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          AppSubText(item.prepTime!, fontSize: 11),
                        ],
                      ),
                    ],

                    // Unavailable badge (vendor-level flag, distinct from stock)
                    if (!item.isAvailable && !item.isOutOfStock) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Unavailable',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Add / quantity controls — disabled if out of stock or unavailable
          Align(
            alignment: Alignment.centerRight,
            child: !canAdd
                ? const SizedBox.shrink()
                : quantity > 0
                ? Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: onDecrement,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.remove, size: 16),
                    ),
                  ),
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '$quantity',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: onIncrement,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, size: 16),
                    ),
                  ),
                ],
              ),
            )
                : SizedBox(
              height: 32,
              child: ElevatedButton.icon(
                onPressed: onAdd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12),
                  elevation: 0,
                ),
                icon: const Icon(Icons.add,
                    size: 16, color: Colors.white),
                label: const Text(
                  'Add',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemImage() {
    final url = item.imageUrl;
    if (url != null && url.isNotEmpty) {
      return AppImage(
        url,
        width: 80,
        height: 80,
        borderRadius: BorderRadius.circular(8),
      );
    }
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.slate200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Icon(Icons.store, size: 32, color: Colors.grey.shade400),
      ),
    );
  }
}