import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/app_image.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/models/menu_item.dart';
import 'package:dropx_mobile/src/core/utils/formatters.dart';
import 'package:dropx_mobile/src/features/cart/providers/cart_provider.dart';

class ItemAddSheet extends ConsumerStatefulWidget {
  final MenuItem item;
  final String vendorId;
  final String vendorName;
  final String zoneId;

  const ItemAddSheet({
    super.key,
    required this.item,
    required this.vendorId,
    required this.vendorName,
    required this.zoneId,
  });

  static Future<void> show(
    BuildContext context, {
    required MenuItem item,
    required String vendorId,
    required String vendorName,
    required String zoneId,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ItemAddSheet(
        item: item,
        vendorId: vendorId,
        vendorName: vendorName,
        zoneId: zoneId,
      ),
    );
  }

  @override
  ConsumerState<ItemAddSheet> createState() => _ItemAddSheetState();
}

class _ItemAddSheetState extends ConsumerState<ItemAddSheet> {
  int _qty = 1;

  // Selected variant id (null = default / no variants).
  String? _selectedVariantId;

  // Selected addon ids.
  final Set<String> _selectedAddonIds = {};

  @override
  void initState() {
    super.initState();
    // Pre-select the default variant.
    final defaultVariant = widget.item.variants
        ?.where((v) => v.isDefault && v.status == 'ACTIVE')
        .firstOrNull;
    _selectedVariantId = defaultVariant?.variantId;
  }

  // ─── Active addon/variant helpers ──────────────────────────────────────────

  List<MenuItemVariant> get _activeVariants =>
      (widget.item.variants ?? [])
          .where((v) => v.status == 'ACTIVE')
          .toList();

  List<MenuItemAddon> get _activeAddons =>
      (widget.item.addons ?? [])
          .where((a) => a.status == 'ACTIVE')
          .toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  // Group active addons by group_name preserving insertion order.
  Map<String, List<MenuItemAddon>> get _addonGroups {
    final result = <String, List<MenuItemAddon>>{};
    for (final addon in _activeAddons) {
      result.putIfAbsent(addon.groupName, () => []).add(addon);
    }
    return result;
  }

  // ─── Price calculation ──────────────────────────────────────────────────────

  double get _variantDelta {
    if (_selectedVariantId == null) return 0;
    return _activeVariants
        .where((v) => v.variantId == _selectedVariantId)
        .map((v) => v.priceDelta)
        .firstOrNull ?? 0;
  }

  double get _addonsTotal => _activeAddons
      .where((a) => _selectedAddonIds.contains(a.addonId))
      .fold(0.0, (sum, a) => sum + a.price);

  double get _unitPrice => widget.item.price + _variantDelta + _addonsTotal;

  double get _total => _unitPrice * _qty;

  // ─── Addon selection (respects max_select per group) ───────────────────────

  void _toggleAddon(MenuItemAddon addon, List<MenuItemAddon> groupAddons) {
    setState(() {
      if (_selectedAddonIds.contains(addon.addonId)) {
        _selectedAddonIds.remove(addon.addonId);
      } else {
        final groupSelected = groupAddons
            .where((a) => _selectedAddonIds.contains(a.addonId))
            .toList();
        if (groupSelected.length >= addon.maxSelect) {
          // Deselect oldest if max reached.
          _selectedAddonIds.remove(groupSelected.first.addonId);
        }
        _selectedAddonIds.add(addon.addonId);
      }
    });
  }

  // ─── Add to cart ────────────────────────────────────────────────────────────

  MenuItemVariant? get _selectedVariant => _activeVariants
      .where((v) => v.variantId == _selectedVariantId)
      .firstOrNull;

  List<MenuItemAddon> get _selectedAddonsList =>
      _activeAddons.where((a) => _selectedAddonIds.contains(a.addonId)).toList();

  void _addToCart() {
    final notifier = ref.read(cartProvider.notifier);
    for (var i = 0; i < _qty; i++) {
      final result = notifier.addToCart(
        widget.item,
        vendorId: widget.vendorId,
        vendorName: widget.vendorName,
        zoneId: widget.zoneId,
        selectedVariant: _selectedVariant,
        selectedAddons: _selectedAddonsList,
      );
      if (result == AddToCartResult.vendorConflict) {
        _showVendorConflictDialog();
        return;
      }
    }
    Navigator.pop(context);
  }

  void _showVendorConflictDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const AppText('Different Vendor', fontWeight: FontWeight.bold),
        content: const AppText(
          'You already have items from another vendor in your cart. Would you like to clear your cart and add this item?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const AppText('Cancel', color: AppColors.grayText),
          ),
          TextButton(
            onPressed: () {
              final notifier = ref.read(cartProvider.notifier);
              notifier.clearCart();
              for (var i = 0; i < _qty; i++) {
                notifier.addToCart(
                  widget.item,
                  vendorId: widget.vendorId,
                  vendorName: widget.vendorName,
                  zoneId: widget.zoneId,
                  selectedVariant: _selectedVariant,
                  selectedAddons: _selectedAddonsList,
                );
              }
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const AppText(
              'Clear & Add',
              color: AppColors.primaryOrange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final hasImage = item.imageUrl != null && item.imageUrl!.isNotEmpty;
    final showVariants = _activeVariants.length > 1;
    final groups = _addonGroups;

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
                    // ── Image ─────────────────────────────────────────────
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

                    // ── Name + price ───────────────────────────────────────
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
                          Formatters.formatNaira(item.price),
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

                    // ── Variants ───────────────────────────────────────────
                    if (showVariants) ...[
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 12),
                      _sectionHeader('Choose a size', required: true),
                      const SizedBox(height: 10),
                      ..._activeVariants.map((v) {
                        final selected = _selectedVariantId == v.variantId;
                        return _selectionTile(
                          id: v.variantId,
                          label: v.name,
                          priceSuffix: v.priceDelta > 0
                              ? '+${Formatters.formatNaira(v.priceDelta)}'
                              : null,
                          selected: selected,
                          isRadio: true,
                          onTap: () =>
                              setState(() => _selectedVariantId = v.variantId),
                        );
                      }),
                    ],

                    // ── Addon groups ───────────────────────────────────────
                    for (final entry in groups.entries) ...[
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 12),
                      _sectionHeader(
                        entry.key,
                        required: entry.value.any((a) => a.required),
                        maxSelect: entry.value.first.maxSelect,
                      ),
                      const SizedBox(height: 10),
                      ...entry.value.map((addon) {
                        final selected =
                            _selectedAddonIds.contains(addon.addonId);
                        return _selectionTile(
                          id: addon.addonId,
                          label: addon.name,
                          priceSuffix: addon.price > 0
                              ? '+${Formatters.formatNaira(addon.price)}'
                              : 'Free',
                          selected: selected,
                          isRadio: addon.maxSelect == 1,
                          onTap: () => _toggleAddon(addon, entry.value),
                        );
                      }),
                    ],

                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 12),

                    // ── Quantity ───────────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const AppText(
                          'Quantity',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        _qtyPicker(),
                      ],
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── Add to cart button ─────────────────────────────────────────
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
                    onPressed: _addToCart,
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
                          Formatters.formatNaira(_total),
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

  // ─── Helper widgets ─────────────────────────────────────────────────────────

  Widget _sectionHeader(
    String title, {
    bool required = false,
    int? maxSelect,
  }) {
    return Row(
      children: [
        Expanded(
          child: AppText(title, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        if (required)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primaryOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: AppText(
              'Required',
              fontSize: 10,
              color: AppColors.primaryOrange,
              fontWeight: FontWeight.w600,
            ),
          )
        else if (maxSelect != null && maxSelect > 1)
          AppSubText(
            'Pick up to $maxSelect',
            fontSize: 11,
            color: Colors.grey.shade500,
          )
        else
          AppSubText('Optional', fontSize: 11, color: Colors.grey.shade500),
      ],
    );
  }

  Widget _selectionTile({
    required String id,
    required String label,
    String? priceSuffix,
    required bool selected,
    required bool isRadio,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryOrange.withValues(alpha: 0.06)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
                selected ? AppColors.primaryOrange : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: isRadio ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: isRadio ? null : BorderRadius.circular(5),
                color: selected ? AppColors.primaryOrange : Colors.white,
                border: Border.all(
                  color: selected
                      ? AppColors.primaryOrange
                      : Colors.grey.shade400,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppText(
                label,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (priceSuffix != null)
              AppText(
                priceSuffix,
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
          ],
        ),
      ),
    );
  }

  Widget _qtyPicker() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        _qtyButton(
          icon: Icons.remove,
          onTap: _qty > 1 ? () => setState(() => _qty--) : null,
        ),
        SizedBox(
          width: 36,
          child: Center(
            child: Text(
              '$_qty',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        _qtyButton(icon: Icons.add, onTap: () => setState(() => _qty++)),
      ],
    ),
  );

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
