import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';

class PollVotingScreen extends StatefulWidget {
  final List<String> options;

  const PollVotingScreen({super.key, required this.options});

  @override
  State<PollVotingScreen> createState() => _PollVotingScreenState();
}

class _PollVotingScreenState extends State<PollVotingScreen> {
  int? _selectedOptionIndex;
  // Mock vote counts
  final Map<int, int> _votes = {};
  final int _totalVotes = 7;

  @override
  Widget build(BuildContext context) {
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
                  "8:57",
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
        leading: const Icon(Icons.arrow_back, color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Confetti / Success Icon
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.secondaryGreen,
                    size: 60,
                  ), // Placeholder for emoji
                  const SizedBox(height: 16),
                  const AppText(
                    "Poll Created! 🎉",
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 8),
                  AppText(
                    "Share the link with your friends so they can vote",
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Options List
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.slate50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    "OPTIONS",
                    fontSize: 10,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 16),
                  ...widget.options.asMap().entries.map((entry) {
                    final index = entry.key;
                    final text = entry.value;
                    final isSelected = _selectedOptionIndex == index;
                    final voteCount = _votes[index] ?? 0;
                    final percentage = _totalVotes > 0
                        ? (voteCount / _totalVotes)
                        : 0.0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedOptionIndex = index;
                            // Simulate adding a vote
                            // In real app, this would call backend
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryOrange
                                  : Colors.transparent,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: isSelected
                                ? AppColors.primaryOrange.withOpacity(0.05)
                                : Colors.transparent,
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: const Color(
                                  0xFFFFE4D6,
                                ), // Light orange
                                child: Text(
                                  "${index + 1}",
                                  style: const TextStyle(
                                    color: AppColors.primaryOrange,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppText(
                                  text,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: AppColors.primaryOrange,
                                  size: 20,
                                )
                              else
                                Radio(
                                  value: index,
                                  groupValue: _selectedOptionIndex,
                                  onChanged: (val) {
                                    setState(() {
                                      _selectedOptionIndex = val;
                                    });
                                  },
                                  activeColor: AppColors.primaryOrange,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 24),
            // Expiry
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppColors.warningAmber,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Expires in 15 minutes",
                    style: TextStyle(
                      color: AppColors.warningAmber,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Share Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.share, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      "Share via WhatsApp",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
