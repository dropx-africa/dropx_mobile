import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';

class OrderStatusBadge extends StatelessWidget {
  final String status;

  const OrderStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String displayText = status.replaceAll('_', ' ');

    switch (status.toUpperCase()) {
      case 'DELIVERED':
      case 'COMPLETED':
        bgColor = const Color(0xFFD1FAE5); // Emerald 100
        textColor = const Color(0xFF065F46); // Emerald 800
        break;
      case 'PAYMENT_PENDING':
      case 'PENDING':
        bgColor = const Color(0xFFFEF3C7); // Amber 100
        textColor = const Color(0xFF92400E); // Amber 800
        break;
      case 'ACTIVE':
      case 'PROCESSING':
        bgColor = const Color(0xFFDBEAFE); // Blue 100
        textColor = const Color(0xFF1E40AF); // Blue 800
        break;
      case 'CANCELLED':
      case 'FAILED':
        bgColor = const Color(0xFFFEE2E2); // Red 100
        textColor = const Color(0xFF991B1B); // Red 800
        break;
      case 'PICKED_UP':
      case 'ON_THE_WAY':
        bgColor = const Color(0xFFF3E8FF); // Purple 100
        textColor = const Color(0xFF6B21A8); // Purple 800
        break;
      default:
        bgColor = const Color(0xFFF1F5F9); // Slate 100
        textColor = const Color(0xFF475569); // Slate 600
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: AppText(
        displayText,
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    );
  }
}
