import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/route/page.dart';

/// Loads the Paystack authorization URL in a WebView.
///
/// When the payment is completed (Paystack redirects back), the screen
/// navigates to the [OrderSuccessScreen].
class PaystackCheckoutScreen extends StatefulWidget {
  final String authorizationUrl;
  final String? reference;
  final String? orderId;

  const PaystackCheckoutScreen({
    super.key,
    required this.authorizationUrl,
    this.reference,
    this.orderId,
  });

  @override
  State<PaystackCheckoutScreen> createState() => _PaystackCheckoutScreenState();
}

class _PaystackCheckoutScreenState extends State<PaystackCheckoutScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

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

            // Detect Paystack callback / success redirect.
            // Paystack appends ?trxref=...&reference=... to the callback URL.
            if (url.contains('trxref=') || url.contains('reference=')) {
              // Payment completed — navigate to success screen.
              _onPaymentComplete();
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.authorizationUrl));
  }

  void _onPaymentComplete() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoute.orderSuccess,
      (route) => false,
      arguments: {'orderId': widget.orderId, 'reference': widget.reference},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppText(
          'Complete Payment',
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => _showCancelDialog(),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange),
            ),
        ],
      ),
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const AppText('Cancel Payment?', fontWeight: FontWeight.bold),
        content: const AppText(
          'Your order has been created. You can retry payment later from your orders.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const AppText(
              'Continue Paying',
              color: AppColors.primaryOrange,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context); // Pop back to cart / previous screen
            },
            child: const AppText('Cancel', color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
