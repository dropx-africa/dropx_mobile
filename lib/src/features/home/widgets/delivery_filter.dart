import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';

class DeliveryFilter extends StatelessWidget {
  final int? selectedEta;
  final ValueChanged<int?> onFilterChanged;

  const DeliveryFilter({
    super.key,
    required this.selectedEta,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterChip('Under 35 min', 35),
          const SizedBox(width: 12),
          _buildFilterChip('Under 60 min', 60),
          const SizedBox(width: 12),
          _buildFilterChip('Explore All', null),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int? etaValue) {
    final isSelected = selectedEta == etaValue;

    return Expanded(
      child: Material(
        color: isSelected ? AppColors.secondaryGreen : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
        child: InkResponse(
          onTap: () => onFilterChanged(etaValue),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (etaValue == 35)
                  const Icon(Icons.bolt, color: Colors.white, size: 16),
                if (etaValue == null)
                  const Icon(Icons.explore, color: Colors.black54, size: 16),
                const SizedBox(width: 4),
                AppText(
                  label,
                  color: isSelected ? Colors.white : Colors.black87,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
