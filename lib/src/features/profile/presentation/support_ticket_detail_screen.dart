import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/features/support/providers/support_providers.dart';
import 'package:intl/intl.dart';

class SupportTicketDetailScreen extends ConsumerWidget {
  final String ticketId;

  const SupportTicketDetailScreen({super.key, required this.ticketId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketAsyncValue = ref.watch(
      supportTicketDetailFutureProvider(ticketId),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: AppText(
          "Ticket $ticketId",
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
      ),
      body: ticketAsyncValue.when(
        data: (ticket) {
          Color statusColor;
          Color statusBgColor;

          switch (ticket.status) {
            case "OPEN":
            case "IN_PROGRESS":
              statusColor = AppColors.primaryOrange;
              statusBgColor = AppColors.primaryOrange.withValues(alpha: 0.1);
              break;
            case "RESOLVED":
              statusColor = AppColors.successGreen;
              statusBgColor = AppColors.successGreen.withValues(alpha: 0.1);
              break;
            case "CLOSED":
            default:
              statusColor = AppColors.slate500;
              statusBgColor = AppColors.slate100;
              break;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: AppText(
                        ticket.status,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    AppText(
                      DateFormat(
                        'MMM dd, yyyy • hh:mm a',
                      ).format(ticket.createdAt.toLocal()),
                      fontSize: 12,
                      color: AppColors.slate500,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                AppText(
                  ticket.subject,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.slate200),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: AppText(
                        ticket.category,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.slate200),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: AppText(
                        ticket.priority,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: ticket.priority == 'HIGH'
                            ? Colors.red
                            : AppColors.slate500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const AppText(
                  "MESSAGE",
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: AppColors.slate400,
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.slate200),
                  ),
                  child: AppText(
                    ticket.message,
                    fontSize: 15,
                    height: 1.5,
                    color: AppColors.slate500,
                  ),
                ),
                const SizedBox(height: 32),
                const AppText(
                  "REPLIES",
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: AppColors.slate400,
                ),
                const SizedBox(height: 16),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.speaker_notes_off_outlined,
                          size: 48,
                          color: AppColors.slate200,
                        ),
                        const SizedBox(height: 16),
                        const AppText(
                          "No replies yet",
                          color: AppColors.slate500,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryOrange),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              AppText('Error: $error', textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
