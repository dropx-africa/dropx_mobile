import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/route/page.dart';
import 'package:dropx_mobile/src/features/parcel/presentation/generic_order_screen.dart'; // Import for OrderType enum

class PollResultScreen extends StatelessWidget {
  const PollResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data
    final List<Map<String, dynamic>> results = [
      {
        'name': 'Jollof Rice',
        'percentage': 0.63,
        'votes': 5,
        'isWinning': true,
        'icon': '🍛',
      },
      {
        'name': 'Pizza',
        'percentage': 0.25,
        'votes': 2,
        'isWinning': false,
        'icon': '🍕',
      },
      {
        'name': 'Shawarma',
        'percentage': 0.13,
        'votes': 1,
        'isWinning': false,
        'icon': '🌯',
      },
    ];

    final winningItem = results.firstWhere((item) => item['isWinning'] == true);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              "Group Poll",
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            AppText(
              "Created by You",
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE6FFFA),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: const [
                Icon(Icons.timer_outlined, size: 14, color: Color(0xFF10B981)),
                SizedBox(width: 4),
                Text(
                  "8:49",
                  style: TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Results List
            ...results.map((item) => _buildResultItem(item)),

            const Spacer(),

            // Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED), // Light orange bg
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.workspace_premium,
                      color: AppColors.primaryOrange,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const AppText(
                    "Currently winning...",
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  const SizedBox(height: 8),
                  AppText(
                    "${winningItem['icon']} ${winningItem['name']}",
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryOrange,
                  ),
                  const SizedBox(height: 8),
                  AppText(
                    "Still time to change the outcome!",
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Order Now Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to Generic Order Screen for Retail/Food
                  Navigator.pushNamed(
                    context,
                    AppRoute.genericOrder, // We need to define this
                    arguments: {
                      'orderType': OrderType.retail, // Assuming Food/Retail
                      'preFilledItem': winningItem['name'],
                      'quantity': winningItem['votes'],
                      'isGroupOrder': true,
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppText(
                      "Order ${winningItem['name']} Now!",
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      winningItem['icon'],
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: item['isWinning'] ? const Color(0xFFFFF7ED) : AppColors.slate50,
        borderRadius: BorderRadius.circular(12),
        border: item['isWinning']
            ? Border.all(color: AppColors.primaryOrange)
            : null,
      ),
      child: Stack(
        children: [
          // Progress Bar Background (if winning, entire card is slightly colored, but bar needs to be distinct)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: FractionallySizedBox(
              widthFactor: item['percentage'],
              child: Container(
                height: 70, // Match container height approx
                color: item['isWinning']
                    ? AppColors.primaryOrange.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.1),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Text(
                    item['icon'],
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AppText(item['name'], fontWeight: FontWeight.bold),
                          if (item['isWinning']) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryOrange,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const AppText(
                                "Leading",
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      AppText(
                        "Chioma, Emeka, Tunde +2",
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AppText(
                      "${(item['percentage'] * 100).toInt()}%",
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    AppText(
                      "${item['votes']} votes",
                      fontSize: 12,
                      color: Colors.grey.shade500,
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
