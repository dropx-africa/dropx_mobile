import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';

class RecentOrdersSection extends StatelessWidget {
  const RecentOrdersSection({super.key});

  @override
  Widget build(BuildContext context) {
    // // Mock data - replace with actual orders from state/API
    // const hasOrders = true;

    // // if (!hasOrders) {
    // //   return const SizedBox.shrink();
    // // }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            'Recent Orders',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (context, index) {
                return Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        'Mama Put\'s Kitchen',
                        fontWeight: FontWeight.bold,
                      ),
                      SizedBox(height: 4),
                      AppSubText('Jollof Rice', fontSize: 12),
                      Spacer(),
                      AppSubText('2 days ago', fontSize: 11),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
