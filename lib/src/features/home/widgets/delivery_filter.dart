import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';

class DeliveryFilter extends StatefulWidget {
  const DeliveryFilter({super.key});

  @override
  State<DeliveryFilter> createState() => _DeliveryFilterState();
}

class _DeliveryFilterState extends State<DeliveryFilter> {
  int _selectedFilter = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterChip('Under 35 min', 0),
          const SizedBox(width: 12),
          _buildFilterChip('Under 60 min', 1),
          const SizedBox(width: 12),
          _buildFilterChip('Explore All', 2),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isSelected = _selectedFilter == index;

    return Expanded(
      child: Material(
        color: isSelected ? AppColors.secondaryGreen : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
        child: InkResponse(
          onTap: () {
            setState(() {
              _selectedFilter = index;
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (index == 0)
                  const Icon(Icons.bolt, color: Colors.white, size: 16),
                if (index == 2)
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
