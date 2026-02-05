import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/app_text_field.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Food',
    'Pharmacy',
    'Parcel',
    'Retail',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const AppText(
          "Discover",
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppTextField(
              hintText: "Search for food, groceries...",
              // prefixIcon: const Icon(Icons.search), // Simple wrapper update needed if we want prefix search
            ),
          ),
          const SizedBox(height: 16),

          // Categories Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: AppText(
                      category,
                      color: isSelected
                          ? Colors.white
                          : AppColors.darkBackground,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    selectedColor: AppColors.primaryOrange,
                    backgroundColor: AppColors.slate50,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // List results
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 5, // Mock items
              itemBuilder: (context, index) {
                return _buildDiscoverCard(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoverCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 140,
            decoration: const BoxDecoration(
              color: AppColors.slate200,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              // image: DecorationImage(...) // Add placeholder image
            ),
            child: Center(
              child: Icon(Icons.image, size: 48, color: Colors.grey.shade400),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const AppText(
                      "Chicken Republic - Lekki",
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.star, size: 12, color: Colors.green),
                          SizedBox(width: 4),
                          Text(
                            "4.5",
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    AppText(
                      "Fast Food • 25-35 min",
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "₦500 delivery",
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
