import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';

class QuickAddWidget extends StatelessWidget {
  final Function(String) onAdd;

  const QuickAddWidget({super.key, required this.onAdd});

  final List<Map<String, String>> _quickOptions = const [
    {'emoji': '🍚', 'text': 'Jollof Rice'},
    {'emoji': '🍕', 'text': 'Pizza'},
    {'emoji': '🌯', 'text': 'Shawarma'},
    {'emoji': '🥡', 'text': 'Chinese'},
    {'emoji': '🍛', 'text': 'Amala'},
    {'emoji': '🍔', 'text': 'Burgers'},
    {'emoji': '🥩', 'text': 'Suya'},
    {'emoji': '🍛', 'text': 'Fried Rice'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText("Quick Add", fontSize: 16, fontWeight: FontWeight.bold),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _quickOptions.map((option) {
              return GestureDetector(
                onTap: () => onAdd(option['text']!),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Text(
                        option['emoji']!,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      AppText(
                        option['text']!,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
