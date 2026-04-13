import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/app_image.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/models/menu_item.dart';

/// Dummy extra option — replace with real model once API is confirmed.
class _DummyExtra {
  final String id;
  final String name;
  final double price;

  const _DummyExtra({required this.id, required this.name, required this.price});
}

// TODO: Replace dummy extras with real API data once endpoint is confirmed.
const _dummyExtras = <_DummyExtra>[
  _DummyExtra(id: 'ex1', name: 'Extra Sauce', price: 150),
  _DummyExtra(id: 'ex2', name: 'Extra Protein', price: 300),
  _DummyExtra(id: 'ex3', name: 'Extra Cheese', price: 200),
  _DummyExtra(id: 'ex4', name: 'Side Salad', price: 500),
];

/// Bottom sheet shown when the user taps "Add" on a menu item.
///
/// Displays item details, optional extras (currently dummy data), and a
/// quantity picker. Calls [onConfirm] with the chosen quantity and total
/// price (base + selected extras) so the caller can add to cart.
class ItemAddSheet extends StatefulWidget {
  final MenuItem item;
  final VoidCallback? onConfirm;

  /// Called with (quantity, extrasTotalPrice) so the caller can decide how
  /// to record the extras in the cart.
  final void Function(int quantity, double extrasTotalPrice)? onConfirmWithExtras;

  const ItemAddSheet({
    super.key,
    required this.item,
    this.onConfirm,
    this.onConfirmWithExtras,
  });

  /// Show the sheet and await the result.
  static Future<void> show(
    BuildContext context, {
    required MenuItem item,
    required void Function(int qty, double extrasPrice) onConfirm,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ItemAddSheet(
        item: item,
        onConfirmWithExtras: onConfirm,
      ),
    );
  }

  @override
  State<ItemAddSheet> createState() => _ItemAddSheetState();
}

class _ItemAddSheetState extends State<ItemAddSheet> {
  int _qty = 1;
  final Set<String> _selectedExtras = {};

  double get _extrasTotal => _dummyExtras
      .where((e) => _selectedExtras.contains(e.id))
      .fold(0, (sum, e) => sum + e.price);

  double get _total => (widget.item.price + _extrasTotal) * _qty;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final hasImage = item.imageUrl != null && item.imageUrl!.isNotEmpty;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Drag handle
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 4),

            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item image
                    if (hasImage)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AppImage(
                          item.imageUrl!,
                          width: double.infinity,
                          height: 180,
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        height: 180,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.fastfood_outlined,
                          size: 56,
                          color: Colors.grey.shade300,
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Name + price row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AppText(
                            item.name,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        AppText(
                          '₦${item.price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryOrange,
                        ),
                      ],
                    ),

                    if (item.description != null &&
                        item.description!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      AppSubText(
                        item.description!,
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ],

                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 12),

                    // ── Extras section ──────────────────────────────────────
                    const AppText(
                      'Add Extras',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 4),
                    AppSubText(
                      'Customise your order (optional)',
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 10),

                    ..._dummyExtras.map((extra) {
                      final selected = _selectedExtras.contains(extra.id);
                      return GestureDetector(
                        onTap: () => setState(() {
                          if (selected) {
                            _selectedExtras.remove(extra.id);
                          } else {
                            _selectedExtras.add(extra.id);
                          }
                        }),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primaryOrange.withValues(alpha: 0.06)
                                : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selected
                                  ? AppColors.primaryOrange
                                  : Colors.grey.shade200,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: selected
                                      ? AppColors.primaryOrange
                                      : Colors.white,
                                  border: Border.all(
                                    color: selected
                                        ? AppColors.primaryOrange
                                        : Colors.grey.shade400,
                                  ),
                                ),
                                child: selected
                                    ? const Icon(
                                        Icons.check,
                                        size: 14,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppText(
                                  extra.name,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              AppText(
                                '+₦${extra.price.toInt()}',
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),

                    // ── Quantity picker ────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const AppText(
                          'Quantity',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              _qtyButton(
                                icon: Icons.remove,
                                onTap: _qty > 1
                                    ? () => setState(() => _qty--)
                                    : null,
                              ),
                              SizedBox(
                                width: 36,
                                child: Center(
                                  child: Text(
                                    '$_qty',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              _qtyButton(
                                icon: Icons.add,
                                onTap: () => setState(() => _qty++),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── Add to cart button ────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onConfirmWithExtras?.call(_qty, _extrasTotal);
                      widget.onConfirm?.call();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: AppText(
                            '$_qty',
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const AppText(
                          'Add to Cart',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        AppText(
                          '₦${_total.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qtyButton({required IconData icon, VoidCallback? onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: onTap != null ? Colors.white : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 18,
            color: onTap != null ? Colors.black87 : Colors.grey.shade400,
          ),
        ),
      );
}
