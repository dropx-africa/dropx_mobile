import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/models/cost_breakdown.dart';
import 'package:dropx_mobile/src/utils/currency_utils.dart';
import 'package:dropx_mobile/src/core/utils/formatters.dart';

/// Renders `cost_breakdown.lines[]` sorted by `sort_order`.
/// Falls back to [fallbackRows] when no lines are available.
///
/// Pass [onDark] for screens with a dark background (white text).
class CostBreakdownWidget extends StatelessWidget {
  final CostBreakdown? costBreakdown;

  /// Shown when costBreakdown is null or has no lines.
  final List<CostFallbackRow> fallbackRows;

  /// When true renders labels/values in white (dark-background screens).
  final bool onDark;

  const CostBreakdownWidget({
    super.key,
    this.costBreakdown,
    this.fallbackRows = const [],
    this.onDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final lines = costBreakdown?.lines ?? [];
    if (lines.isNotEmpty) {
      final sorted = [...lines]
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return Column(
        children: sorted.map((line) => _LineRow(line: line, onDark: onDark)).toList(),
      );
    }

    // Fallback
    return Column(
      children: fallbackRows
          .map((r) => CostFallbackRowWidget(row: r, onDark: onDark))
          .toList(),
    );
  }
}

class _LineRow extends StatelessWidget {
  final CostBreakdownLine line;
  final bool onDark;

  const _LineRow({required this.line, required this.onDark});

  @override
  Widget build(BuildContext context) {
    final isTotal = line.type == 'total' || (line.emphasis ?? false);
    final labelColor = onDark
        ? (isTotal ? Colors.white : Colors.grey.shade300)
        : (isTotal ? Colors.black : Colors.grey.shade600);
    final valueColor = isTotal ? AppColors.primaryOrange : (onDark ? Colors.white : Colors.black);
    final amount = Formatters.formatNaira(
      CurrencyUtils.koboToNaira(line.amountKobo),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            line.label,
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: labelColor,
          ),
          AppText(
            amount,
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: valueColor,
          ),
        ],
      ),
    );
  }
}

/// A single fallback row for when `cost_breakdown.lines` is absent.
class CostFallbackRow {
  final String label;
  final String value;
  final bool isTotal;

  const CostFallbackRow(this.label, this.value, {this.isTotal = false});
}

class CostFallbackRowWidget extends StatelessWidget {
  final CostFallbackRow row;
  final bool onDark;

  const CostFallbackRowWidget({super.key, required this.row, required this.onDark});

  @override
  Widget build(BuildContext context) {
    final labelColor = onDark
        ? (row.isTotal ? Colors.white : Colors.grey.shade300)
        : (row.isTotal ? Colors.black : Colors.grey.shade600);
    final valueColor = row.isTotal ? AppColors.primaryOrange : (onDark ? Colors.white : Colors.black);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            row.label,
            fontSize: row.isTotal ? 16 : 14,
            fontWeight: row.isTotal ? FontWeight.bold : FontWeight.normal,
            color: labelColor,
          ),
          AppText(
            row.value,
            fontSize: row.isTotal ? 16 : 14,
            fontWeight: row.isTotal ? FontWeight.bold : FontWeight.w600,
            color: valueColor,
          ),
        ],
      ),
    );
  }
}

/// Convenience constructor for fallback rows — keeps call sites readable.
CostFallbackRow costRow(String label, String value, {bool isTotal = false}) =>
    CostFallbackRow(label, value, isTotal: isTotal);
