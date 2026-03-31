import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/common_widgets/app_toast.dart';
import 'package:dropx_mobile/src/common_widgets/app_scaffold.dart';
import 'package:dropx_mobile/src/common_widgets/app_appbar.dart';
import 'package:dropx_mobile/src/features/wallet/data/dto/wallet_topup_verify_request.dart';
import 'package:dropx_mobile/src/features/wallet/providers/wallet_providers.dart';
import 'package:dropx_mobile/src/utils/app_navigator.dart';

class WalletTopupCheckoutScreen extends ConsumerStatefulWidget {
  final String authorizationUrl;
  final String reference;
  final String paymentAttemptId;

  const WalletTopupCheckoutScreen({
    super.key,
    required this.authorizationUrl,
    required this.reference,
    required this.paymentAttemptId,
  });

  @override
  ConsumerState<WalletTopupCheckoutScreen> createState() =>
      _WalletTopupCheckoutScreenState();
}

class _WalletTopupCheckoutScreenState
    extends ConsumerState<WalletTopupCheckoutScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onNavigationRequest: (request) {
            final url = request.url;
            if (url.contains('trxref=') || url.contains('reference=')) {
              _onPaymentComplete();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.authorizationUrl));
  }

  Future<void> _onPaymentComplete() async {
    if (_isVerifying) return;
    setState(() => _isVerifying = true);

    try {
      final walletRepo = ref.read(walletRepositoryProvider);
      final result = await walletRepo.verifyTopup(
        WalletTopupVerifyRequest(
          paymentAttemptId: widget.paymentAttemptId,
          reference: widget.reference,
        ),
      );

      if (!mounted) return;

      if (result.verified) {
        final balanceKobo = int.tryParse(result.availableBalanceKobo) ?? 0;
        ref.read(walletBalanceKoboProvider.notifier).state = balanceKobo;
        AppNavigator.pop(context, true);
      } else {
        _showError('Payment could not be verified. Please try again.');
      }
    } catch (e) {
      if (mounted) _showError('Verification failed: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  void _showError(String message) {
    AppToast.showError(context, message);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppAppBar(
        title: 'Top Up Wallet',
        style: AppAppBarStyle.white,
        showBack: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: _showCancelDialog,
          ),
        ],
      ),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: true,
          child: Stack(
            children: [
              WebViewWidget(controller: _controller),
              if (_isLoading || _isVerifying)
                Container(
                  color: Colors.white.withValues(alpha: 0.7),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          color: AppColors.primaryOrange,
                        ),
                        if (_isVerifying) ...[
                          const SizedBox(height: 16),
                          const AppText(
                            'Verifying payment…',
                            fontSize: 14,
                            color: AppColors.slate500,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const AppText('Cancel Top-Up?', fontWeight: FontWeight.bold),
        content: const AppText(
          'Your wallet top-up will not be completed if you leave now.',
        ),
        actions: [
          TextButton(
            onPressed: () => AppNavigator.pop(ctx),
            child: const AppText(
              'Continue',
              color: AppColors.primaryOrange,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: () {
              AppNavigator.pop(ctx);
              AppNavigator.pop(context, false);
            },
            child: const AppText('Cancel', color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
