import 'package:dropx_mobile/src/core/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/menu_item.dart';
import '../../../../route/page.dart';
import '../../providers/group_order_providers.dart';


class GroupItemAddSheet extends ConsumerStatefulWidget {
  final MenuItem item;
  final String vendorName;
  final String zoneId;
  final String groupOrderId;
  final String participantToken;

  const GroupItemAddSheet({
    super.key,
    required this.item,
    required this.vendorName,
    required this.zoneId,
    required this.groupOrderId,
    required this.participantToken,
  });

  static Future<void> show(
      BuildContext context, {
        required MenuItem item,
        required String vendorName,
        required String zoneId,
        required String groupOrderId,
        required String participantToken,
      }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GroupItemAddSheet(
        item: item,
        vendorName: vendorName,
        zoneId: zoneId,
        groupOrderId: groupOrderId,
        participantToken: participantToken,
      ),
    );
  }

  @override
  ConsumerState<GroupItemAddSheet> createState() => _GroupItemAddSheetState();
}

class _GroupItemAddSheetState extends ConsumerState<GroupItemAddSheet> {
  int _quantity = 1;
  MenuItemVariant? _selectedVariant;
  final List<MenuItemAddon> _selectedAddons = [];
  bool _isLoading = false;

  double get _basePrice {
    if (_selectedVariant != null) {
      return widget.item.price + _selectedVariant!.priceDelta;
    }
    return widget.item.price;
  }

  double get _addonsTotal =>
      _selectedAddons.fold(0, (sum, a) => sum + a.price);

  double get _total => (_basePrice + _addonsTotal) * _quantity;

  void _toggleAddon(MenuItemAddon addon) {
    setState(() {
      if (_selectedAddons.any((a) => a.addonId == addon.addonId)) {
        _selectedAddons.removeWhere((a) => a.addonId == addon.addonId);
      } else {
        _selectedAddons.add(addon);
      }
    });
  }

  Future<void> _addToGroupOrder() async {
    setState(() => _isLoading = true);
    try {
      final configuration = <String, dynamic>{
        'selected_variant': _selectedVariant == null
            ? null
            : {
          'variant_id': _selectedVariant!.variantId,
          'name': _selectedVariant!.name,
          'price_delta_kobo':
          (_selectedVariant!.priceDelta * 100).toInt(),
        },
        'selected_addons': _selectedAddons
            .map((a) => {
          'addon_id': a.addonId,
          'name': a.name,
          'price_kobo': (a.price * 100).toInt(),
        })
            .toList(),
      };

      await ref.read(groupOrderProvider.notifier).addItem(
        itemId: widget.item.id,
        itemName: widget.item.name,
        unitPriceKobo: widget.item.price * 100,
        quantity: _quantity,
        configuration: configuration,
      );

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text('${widget.item.name} added to group cart'),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.secondaryGreen,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.popUntil(
          context,
              (route) => route.settings.name == AppRoute.groupOrder,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add item: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasVariants =
        widget.item.variants != null && widget.item.variants!.isNotEmpty;
    final hasAddons =
        widget.item.addons != null && widget.item.addons!.isNotEmpty;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // ── Drag handle ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

              // ── Scrollable content ────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Item hero ─────────────────────────────────────
                      _ItemHero(item: widget.item),
                      const SizedBox(height: 20),

                      // ── Group order context pill ──────────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryOrange.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                            AppColors.primaryOrange.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.group_outlined,
                                size: 14, color: AppColors.primaryOrange),
                            const SizedBox(width: 6),
                            AppText(
                              'Adding to group cart at ${widget.vendorName}',
                              fontSize: 12,
                              color: AppColors.primaryOrange,
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Variants ──────────────────────────────────────
                      if (hasVariants) ...[
                        _SectionLabel('Choose size'),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: widget.item.variants!.map((variant) {
                            final isSelected =
                                _selectedVariant?.variantId == variant.variantId;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedVariant = variant),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.darkBackground
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.darkBackground
                                        : Colors.grey.shade200,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText(
                                      variant.name,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                    if (variant.priceDelta != 0)
                                      AppText(
                                        variant.priceDelta > 0
                                            ? '+${Formatters.formatNaira(variant.priceDelta)}'
                                            : '-${Formatters.formatNaira(variant.priceDelta.abs())}',
                                        fontSize: 11,
                                        color: isSelected
                                            ? Colors.white60
                                            : AppColors.slate400,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // ── Add-ons ───────────────────────────────────────
                      if (hasAddons) ...[
                        _SectionLabel('Add extras'),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: Column(
                            children:
                            widget.item.addons!.asMap().entries.map((e) {
                              final addon = e.value;
                              final isLast =
                                  e.key == widget.item.addons!.length - 1;
                              final isSelected = _selectedAddons
                                  .any((a) => a.addonId == addon.addonId);
                              return Column(
                                children: [
                                  InkWell(
                                    onTap: () => _toggleAddon(addon),
                                    borderRadius: BorderRadius.circular(16),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 14),
                                      child: Row(
                                        children: [
                                          AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 150),
                                            width: 22,
                                            height: 22,
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? AppColors.primaryOrange
                                                  : Colors.white,
                                              borderRadius:
                                              BorderRadius.circular(6),
                                              border: Border.all(
                                                color: isSelected
                                                    ? AppColors.primaryOrange
                                                    : Colors.grey.shade300,
                                                width: 1.5,
                                              ),
                                            ),
                                            child: isSelected
                                                ? const Icon(Icons.check,
                                                size: 14,
                                                color: Colors.white)
                                                : null,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: AppText(
                                              addon.name,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          AppText(
                                            '+${Formatters.formatNaira(addon.price)}',
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.slate400,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (!isLast)
                                    Divider(
                                        height: 1,
                                        color: Colors.grey.shade100,
                                        indent: 16),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // ── Quantity ──────────────────────────────────────
                      _SectionLabel('Quantity'),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _QuantityButton(
                            icon: Icons.remove,
                            onTap: _quantity > 1
                                ? () => setState(() => _quantity--)
                                : null,
                          ),
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 24),
                            child: AppText(
                              '$_quantity',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          _QuantityButton(
                            icon: Icons.add,
                            onTap: () => setState(() => _quantity++),
                            filled: true,
                          ),
                          const Spacer(),
                          // Running total
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              AppText(
                                Formatters.formatNaira(_total),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryOrange,
                              ),
                              AppText(
                                'total',
                                fontSize: 11,
                                color: AppColors.slate400,
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),

              // ── Sticky bottom button ──────────────────────────────────
              Container(
                padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad + 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _addToGroupOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      disabledBackgroundColor:
                      AppColors.primaryOrange.withValues(alpha: 0.5),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shopping_bag_outlined,
                            color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        AppText(
                          'Add to Group Cart • ${Formatters.formatNaira(_total)}',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _ItemHero extends StatelessWidget {
  final MenuItem item;
  const _ItemHero({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: item.imageUrl != null && item.imageUrl!.isNotEmpty
              ? Image.network(
            item.imageUrl!,
            width: 90,
            height: 90,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _imagePlaceholder(),
          )
              : _imagePlaceholder(),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                item.name,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              if (item.description != null &&
                  item.description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                AppText(
                  item.description!,
                  fontSize: 12,
                  color: AppColors.slate400,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              AppText(
                Formatters.formatNaira(item.price),
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryOrange,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(Icons.fastfood_outlined,
          size: 32, color: AppColors.slate200),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return AppText(
      text,
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: AppColors.darkBackground,
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool filled;

  const _QuantityButton({
    required this.icon,
    this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: filled
              ? AppColors.darkBackground
              : onTap != null
              ? Colors.white
              : AppColors.slate50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: filled
                ? AppColors.darkBackground
                : onTap != null
                ? Colors.grey.shade300
                : Colors.grey.shade200,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: filled
              ? Colors.white
              : onTap != null
              ? Colors.black87
              : AppColors.slate200,
        ),
      ),
    );
  }
}