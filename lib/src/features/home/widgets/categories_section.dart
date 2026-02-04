import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/features/home/widgets/category_button.dart';

class CategoriesSection extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategoriesSection({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final List<Map<String, dynamic>> categories = const [
    {'icon': Icons.restaurant, 'label': 'Food'},
    {'icon': Icons.local_pharmacy, 'label': 'Pharmacy'},
    {'icon': Icons.card_giftcard, 'label': 'Parcel'},
    {'icon': Icons.shopping_cart, 'label': 'Retail'},
    {'icon': Icons.local_grocery_store, 'label': 'Groceries'},
    {'icon': Icons.liquor, 'label': 'Drinks'},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CategoryButton(
              icon: category['icon'] as IconData,
              label: category['label'] as String,
              isSelected: selectedCategory == category['label'],
              onTap: () => onCategorySelected(category['label'] as String),
            ),
          );
        },
      ),
    );
  }
}
