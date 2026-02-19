import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/route/page.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  // Stages: 0: Placed, 1: Accepted, 2: Arrived, 3: Delivered (Before Payment), 4: Completed
  int _orderStage = 0;
  String _status = "Order Placed";
  final String _statusText = "Status"; // Lint fix: made final
  Color _statusColor = Colors.grey;
  Timer? _timer;
  bool _isCodeShared = false;

  @override
  void initState() {
    super.initState();
    _startOrderSimulation();
  }

  void _startOrderSimulation() {
    // Stage 0: Placed
    setState(() {
      _orderStage = 0;
      _status = "Order Placed";
      _statusColor = Colors.grey;
    });

    // Stage 1: Accepted (after 2s)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _orderStage = 1;
          _status = "Order Accepted";
          _statusColor = AppColors.primaryOrange;
        });
      }
    });

    // Stage 2: Rider Arrived (after 5s)
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _orderStage = 2;
          _status = "Rider Arrived";
        });
      }
    });

    // Stage 3: Delivered (Ready for Confirmation) (after 8s)
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) {
        setState(() {
          _orderStage = 3;
          _status = "Order Delivered";
          _statusColor = Colors.green;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Map Placeholder
          Container(
            color: Colors.grey.shade300,
            width: double.infinity,
            height: double.infinity,
            child: const Center(
              child: Icon(Icons.map, size: 64, color: Colors.grey),
            ),
          ),

          // Back Button
          Positioned(
            top: 50,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // 2. Status Sheet (Sticky Bottom)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pull Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Header Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            "Estimated Arrival",
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(height: 4),
                          const AppText(
                            "12 mins",
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          AppText(
                            _statusText,
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(height: 4),
                          AppText(
                            _status,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _statusColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Timeline / Progress Bar
                  _buildProgressBar(context),
                  const SizedBox(height: 24),

                  // Rider Info
                  _buildRiderInfo(),
                  const SizedBox(height: 24),

                  // Dynamic Content based on Stage
                  if (_orderStage < 3) ...[
                    // Active Tracking (Placed/Accepted/Arrived)
                    // No actions needed, just wait
                  ] else if (_orderStage == 3) ...[
                    // Order Delivered -> Confirm & Pay
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => _showPaymentModal(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green, // Visual distinction
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const AppText(
                          "Confirm Delivery & Pay",
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ] else ...[
                    // Order Completed & Paid -> Show OTP
                    // Order Completed & Paid -> Show OTP or Success Options
                    if (!_isCodeShared) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.green.shade100),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.green.shade50,
                        ),
                        child: Column(
                          children: [
                            const AppText(
                              "Order Completed",
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                            const SizedBox(height: 8),
                            const AppText(
                              "Provide this code to the rider:",
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 4),
                            const AppText(
                              "4 8 2 9",
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // I have shared code button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isCodeShared = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryOrange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const AppText(
                            "I have shared the code",
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ] else ...[
                      // Code Shared -> Show Options
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoute.receipt,
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: AppColors.primaryOrange,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const AppText(
                                  "View Receipt",
                                  color: AppColors.primaryOrange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoute.transactionDetails,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryOrange,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const AppText(
                                  "View Transaction",
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12, // Slightly smaller to fit
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widgets

  Widget _buildProgressBar(BuildContext context) {
    double progress = 0.0;
    if (_orderStage >= 1) progress = 0.33;
    if (_orderStage >= 2) progress = 0.66;
    if (_orderStage >= 3) progress = 1.0;

    return SizedBox(
      height: 24, // Fixed height for alignment
      child: Stack(
        alignment: Alignment.center, // Center vertically
        children: [
          // Background Line
          Container(
            height: 4,
            width: double.infinity,
            color: Colors.grey.shade200,
          ),
          // Progress Line
          Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              height: 4,
              width:
                  (MediaQuery.of(context).size.width - 48) *
                  progress, // -48 for padding
              color: AppColors.primaryOrange,
            ),
          ),
          // Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (index) {
              bool isActive = index <= _orderStage;
              return Container(
                width: 16,
                height: 16, // Slightly larger for better visual
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primaryOrange
                      : Colors.grey.shade300,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 2),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildRiderInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Using generated image asset if added, else placeholder
          const CircleAvatar(
            radius: 20,
            // In a real app complexity, we'd copy the generated artifact to assets.
            // For now, using standard icon or if the user manually added it.
            // Putting a network placeholders or local asset logic usually requires setup.
            backgroundImage: AssetImage('assets/images/user.png'),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppText(
                "Musa Ibrahim",
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              const SizedBox(height: 2),
              AppText(
                "Bajaj Boxer • LA-482-KJA",
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              const SizedBox(height: 2),
              const Row(
                children: [
                  Icon(Icons.star, color: AppColors.primaryOrange, size: 12),
                  SizedBox(width: 4),
                  AppText("4.9", fontSize: 12, fontWeight: FontWeight.bold),
                ],
              ),
            ],
          ),
          const Spacer(),
          const CircleAvatar(
            backgroundColor: Colors.white,
            radius: 18,
            child: Icon(
              Icons.message_outlined,
              size: 18,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            backgroundColor: Colors.black,
            radius: 18,
            child: Icon(Icons.call, size: 18, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // Payment Modal Logic
  void _showPaymentModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const AppText(
              "Confirm & Pay",
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 24),
            _buildPaymentOption(
              modalContext: modalContext,
              parentContext: context,
              icon: Icons.account_balance_wallet_outlined,
              title: "Pay from Wallet",
              subtitle: "Balance: ₦50,000",
            ),
            _buildPaymentOption(
              modalContext: modalContext,
              parentContext: context,
              icon: Icons.credit_card,
              title: "Pay with Paystack",
              subtitle: "Cards, Bank Transfer, USSD",
            ),
            _buildPaymentOption(
              modalContext: modalContext,
              parentContext: context,
              icon: Icons.share,
              title: "Share Group Link",
              subtitle: "Split bill with friends",
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required BuildContext modalContext,
    required BuildContext parentContext,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      onTap: () {
        Navigator.pop(modalContext); // Close modal
        _processPayment(parentContext);
      },
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primaryOrange.withValues(
            alpha: 0.1,
          ), // Fixed deprecation
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primaryOrange),
      ),
      title: AppText(title, fontWeight: FontWeight.bold, fontSize: 16),
      subtitle: AppText(subtitle, color: Colors.grey.shade500, fontSize: 12),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
    );
  }

  void _processPayment(BuildContext context) {
    // Show Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primaryOrange),
              const SizedBox(height: 16),
              const AppText(
                "Processing Payment...",
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              const SizedBox(height: 8),
              AppText(
                "Please wait while we confirm your transaction",
                color: Colors.grey.shade600,
                fontSize: 12,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );

    // Mock Success
    Future.delayed(const Duration(seconds: 1), () {
      if (context.mounted) {
        // Check outer context
        Navigator.pop(context); // Close dialog
        setState(() {
          _orderStage = 4; // Completed
          _status = "Delivered & Paid";
        });
      }
    });
  }
}
