import 'package:dropx_mobile/src/common_widgets/app_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/app_spacers.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/features/support/providers/support_providers.dart';
import 'package:dropx_mobile/src/features/support/data/dto/ticket_dto.dart';
import 'package:dropx_mobile/src/features/wallet/providers/wallet_providers.dart';
import 'package:dropx_mobile/src/features/wallet/data/dto/wallet_ledger_response.dart';
import 'package:dropx_mobile/src/route/page.dart';
import 'package:intl/intl.dart';
import 'package:dropx_mobile/src/utils/app_navigator.dart';
import 'package:dropx_mobile/src/common_widgets/app_toast.dart';
import 'package:dropx_mobile/src/common_widgets/app_scaffold.dart';
import 'package:dropx_mobile/src/common_widgets/app_loading_widget.dart';
import 'package:dropx_mobile/src/common_widgets/app_empty_state.dart';
import 'package:dropx_mobile/src/utils/currency_utils.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedCategory = 'PAYMENT';
  String _selectedPriority = 'MEDIUM';
  bool _isSubmittingTicket = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _showSupportTicketSheet() {
    _subjectController.clear();
    _messageController.clear();
    setState(() {
      _selectedCategory = 'PAYMENT';
      _selectedPriority = 'MEDIUM';
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.slate200,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  AppSpaces.v16,
                  const AppText(
                    "Report an Issue",
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  AppSpaces.v4,
                  const AppText(
                    "Describe your wallet or payment issue and our team will get back to you.",
                    fontSize: 13,
                    color: AppColors.slate500,
                  ),
                  AppSpaces.v20,
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: "Category",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'PAYMENT',
                        child: Text('Payment Issue'),
                      ),
                      DropdownMenuItem(
                        value: 'DELIVERY',
                        child: Text('Delivery Issue'),
                      ),
                      DropdownMenuItem(
                        value: 'ACCOUNT',
                        child: Text('Account Issue'),
                      ),
                    ],
                    onChanged: (val) {
                      setModalState(() => _selectedCategory = val!);
                      setState(() => _selectedCategory = val!);
                    },
                  ),
                  AppSpaces.v16,
                  DropdownButtonFormField<String>(
                    initialValue: _selectedPriority,
                    decoration: InputDecoration(
                      labelText: "Priority",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'LOW', child: Text('Low')),
                      DropdownMenuItem(value: 'MEDIUM', child: Text('Medium')),
                      DropdownMenuItem(
                        value: 'HIGH',
                        child: Text('High — Urgent'),
                      ),
                    ],
                    onChanged: (val) {
                      setModalState(() => _selectedPriority = val!);
                      setState(() => _selectedPriority = val!);
                    },
                  ),
                  AppSpaces.v16,
                  TextField(
                    controller: _subjectController,
                    decoration: InputDecoration(
                      labelText: "Subject",
                      hintText: "e.g. Wrong amount deducted",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                  AppSpaces.v16,
                  TextField(
                    controller: _messageController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: "Message",
                      hintText: "Describe the issue in detail...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                  AppSpaces.v24,
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSubmittingTicket
                          ? null
                          : () async {
                              if (_subjectController.text.trim().isEmpty ||
                                  _messageController.text.trim().isEmpty) {
                                AppToast.showError(
                                  context,
                                  'Please fill in subject and message.',
                                );
                                return;
                              }
                              setModalState(() => _isSubmittingTicket = true);
                              setState(() => _isSubmittingTicket = true);
                              try {
                                final dto = CreateTicketDto(
                                  category: _selectedCategory,
                                  subject: _subjectController.text.trim(),
                                  message: _messageController.text.trim(),
                                  priority: _selectedPriority,
                                );
                                await ref
                                    .read(supportRepositoryProvider)
                                    .createTicket(dto);
                                if (!mounted) return;
                                if (sheetContext.mounted) {
                                  AppNavigator.pop(sheetContext);
                                }
                                AppToast.showSuccess(
                                  context,
                                  'Ticket submitted! We\'ll respond shortly.',
                                );
                              } catch (e) {
                                if (!mounted) return;
                                AppToast.showError(
                                  context,
                                  'Failed to submit ticket: $e',
                                );
                              } finally {
                                if (sheetContext.mounted) {
                                  setModalState(
                                    () => _isSubmittingTicket = false,
                                  );
                                }
                                if (mounted) {
                                  setState(() => _isSubmittingTicket = false);
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isSubmittingTicket
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const AppText(
                              "Submit Ticket",
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                    ),
                  ),
                  AppSpaces.v24,
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final balanceAsync = ref.watch(walletBalanceProvider);
    final ledgerAsync = ref.watch(walletLedgerProvider);

    final currencyFormat = NumberFormat.currency(symbol: '₦', decimalDigits: 0);

    return AppScaffold(

      appBar: const AppAppBar(title: 'Wallet', showBack: false),
      children: [
        // Balance Card
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF020B1C), Color(0xFF0D2137)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF020B1C).withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppText(
                    "Wallet Balance",
                    fontSize: 13,
                    color: AppColors.slate400,
                    fontWeight: FontWeight.w500,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const AppText(
                      "Active",
                      fontSize: 11,
                      color: AppColors.secondaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              AppSpaces.v12,
              balanceAsync.when(
                data: (balance) {
                  final naira = CurrencyUtils.koboToNaira(
                    balance.availableBalanceKobo,
                  );
                  return AppText(
                    currencyFormat.format(naira),
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -1,
                  );
                },
                loading: () => const AppText(
                  '—',
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
                error: (_, __) => const AppText(
                  '₦0',
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
              AppSpaces.v20,
              Row(
                children: [
                  Expanded(
                    child: _buildCardAction(
                      icon: Icons.add_rounded,
                      label: "Add Money",
                      onTap: () async {
                        final result = await AppNavigator.push(
                          context,
                          AppRoute.walletTopup,
                        );
                        if (result == true) {
                          ref.invalidate(walletBalanceProvider);
                          ref.invalidate(walletLedgerProvider);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCardAction(
                      icon: Icons.support_agent_rounded,
                      label: "Report Issue",
                      onTap: _showSupportTicketSheet,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        AppSpaces.v24,

        const AppText(
          "TRANSACTION HISTORY",
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: AppColors.slate500,
        ),
        AppSpaces.v12,

        ledgerAsync.when(
          data: (ledger) {
            if (ledger.entries.isEmpty) {
              return _buildEmptyTransactions();
            }
            return Column(
              children: ledger.entries.map((entry) {
                return _buildLedgerEntry(entry, currencyFormat);
              }).toList(),
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.only(top: 40),
            child: AppLoading(),
          ),
          error: (_, __) => _buildEmptyTransactions(),
        ),

        AppSpaces.v24,
      ],
    );
  }

  Widget _buildLedgerEntry(
    WalletLedgerEntry entry,
    NumberFormat currencyFormat,
  ) {
    final isCredit = entry.direction == 'CREDIT';
    final naira = CurrencyUtils.koboToNaira(entry.amountKobo);
    final displayDate = DateFormat(
      'dd MMM, hh:mm a',
    ).format(DateTime.parse(entry.createdAt).toLocal());

    final label = _reasonLabel(entry.reasonCode);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isCredit
                  ? AppColors.secondaryGreen.withValues(alpha: 0.1)
                  : AppColors.errorRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isCredit
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: isCredit ? AppColors.secondaryGreen : AppColors.errorRed,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(label, fontWeight: FontWeight.w600, fontSize: 14),
                AppSpaces.v4,
                AppText(displayDate, fontSize: 12, color: AppColors.slate400),
              ],
            ),
          ),
          AppText(
            '${isCredit ? '+' : '-'}${currencyFormat.format(naira)}',
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: isCredit ? AppColors.secondaryGreen : AppColors.errorRed,
          ),
        ],
      ),
    );
  }

  String _reasonLabel(String reasonCode) {
    switch (reasonCode) {
      case 'WALLET_TOPUP_VERIFIED':
        return 'Wallet Top-up';
      case 'ORDER_PAYMENT':
        return 'Order Payment';
      case 'ORDER_REFUND':
        return 'Order Refund';
      default:
        return reasonCode.replaceAll('_', ' ').toLowerCase().capitalize();
    }
  }

  Widget _buildCardAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            AppText(
              label,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyTransactions() {
    return const AppEmptyState(
      icon: Icons.receipt_long_outlined,
      title: "No transactions yet",
      message: "Your payment history will appear here",
    );
  }
}

extension _StringExt on String {
  String capitalize() => isEmpty ? this : this[0].toUpperCase() + substring(1);
}
