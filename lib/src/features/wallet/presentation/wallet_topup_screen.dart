import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/app_spacers.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/core/providers/core_providers.dart';
import 'package:dropx_mobile/src/features/wallet/data/dto/wallet_topup_initialize_request.dart';
import 'package:dropx_mobile/src/features/wallet/providers/wallet_providers.dart';
import 'package:dropx_mobile/src/common_widgets/app_toast.dart';
import 'package:dropx_mobile/src/utils/app_navigator.dart';
import 'package:dropx_mobile/src/features/wallet/presentation/wallet_topup_checkout_screen.dart';
import 'package:dropx_mobile/src/utils/currency_utils.dart';
import 'package:dropx_mobile/src/route/page.dart';
import 'package:dropx_mobile/src/common_widgets/app_scaffold.dart';

class WalletTopupScreen extends ConsumerStatefulWidget {
  const WalletTopupScreen({super.key});

  @override
  ConsumerState<WalletTopupScreen> createState() => _WalletTopupScreenState();
}

class _WalletTopupScreenState extends ConsumerState<WalletTopupScreen> {
  final _amountController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _startTopup() async {
    final amountText = _amountController.text.trim();
    final amountNaira = double.tryParse(amountText);

    if (amountNaira == null || amountNaira < 1000) {
      AppToast.showError(context, 'Minimum top-up amount is ₦1000');
      return;
    }

    final session = ref.read(sessionServiceProvider);
    final email = session.email;

    if (email.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const AppText('Email Required', fontWeight: FontWeight.bold),
          content: const AppText(
            'Paystack requires an email to process payments. Please update your profile with your email address and try again.',
          ),
          actions: [
            TextButton(
              onPressed: () => AppNavigator.pop(ctx),
              child: const AppText(
                'OK',
                color: AppColors.primaryOrange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final walletRepo = ref.read(walletRepositoryProvider);
      final amountKobo = (amountNaira * 100).round();

      final result = await walletRepo.initializeTopup(
        WalletTopupInitializeRequest(amountKobo: amountKobo, payerEmail: email),
      );

      if (!mounted) return;

      final success = await AppNavigator.push<bool>(
        context,
        AppRoute.walletTopupCheckout,
        arguments: {
          'authorizationUrl': result.authorizationUrl,
          'reference': result.reference,
          'paymentAttemptId': result.paymentAttemptId,
        },
      );

      if (!mounted) return;

      if (success == true) {
        final balanceKobo = ref.read(walletBalanceKoboProvider);
        final balanceNaira = CurrencyUtils.koboToNaira(balanceKobo);
        AppToast.showSuccess(
          context,
          'Wallet topped up! New balance: ₦${balanceNaira.toStringAsFixed(0)}',
        );
        AppNavigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Top-up failed: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        backgroundColor: AppColors.slate50,
        elevation: 0,
        title: const AppText(
          'Add Money',
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => AppNavigator.pop(context),
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppText(
                      'Enter Amount',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate500,
                    ),
                    AppSpaces.v12,
                    TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        prefixText: '₦ ',
                        prefixStyle: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        hintText: '0',
                        hintStyle: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade300,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const Divider(),
                    AppSpaces.v8,
                    const AppText(
                      'Minimum ₦100 · Powered by Paystack',
                      fontSize: 12,
                      color: AppColors.slate400,
                    ),
                  ],
                ),
              ),
              AppSpaces.v16,
              // Quick amount chips
              Wrap(
                spacing: 8,
                children: [500, 1000, 2000, 5000].map((amount) {
                  return ActionChip(
                    label: AppText(
                      '₦$amount',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryOrange,
                    ),
                    backgroundColor: AppColors.primaryOrange.withValues(
                      alpha: 0.08,
                    ),
                    side: BorderSide(
                      color: AppColors.primaryOrange.withValues(alpha: 0.3),
                    ),
                    onPressed: () {
                      _amountController.text = amount.toString();
                    },
                  );
                }).toList(),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _startTopup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    disabledBackgroundColor: AppColors.primaryOrange.withValues(
                      alpha: 0.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const AppText(
                          'Proceed to Payment',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}
