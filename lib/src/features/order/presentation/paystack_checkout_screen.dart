import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/app_toast.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/core/network/api_exceptions.dart';
import 'package:dropx_mobile/src/core/services/app_notifications.dart';
import 'package:dropx_mobile/src/features/order/data/dto/verify_paystack_payment_request.dart';
import 'package:dropx_mobile/src/features/order/providers/order_providers.dart';
import 'package:dropx_mobile/src/features/parcel/data/dto/verify_parcel_paystack_payment_request.dart';
import 'package:dropx_mobile/src/features/parcel/providers/parcel_providers.dart';
import 'package:dropx_mobile/src/features/paylink/providers/paylink_providers.dart';
import 'package:dropx_mobile/src/route/page.dart';

/// What kind of resource this checkout is paying for, and therefore which
/// server-side verification call to make once Paystack redirects back.
///
/// `payLink` polls `GET /pay-links/:token` (the same endpoint the pay-link
/// screen already uses) until the backend's own computed `status` says
/// `PAID` — that status is derived from the real order/parcel state
/// server-side, so this is real verification, not a guess based on the
/// redirect URL.
enum PaystackVerifyKind { order, parcel, payLink, none }

/// Loads the Paystack authorization URL in a WebView.
///
/// When Paystack redirects back, the reference is verified against the
/// backend (unless [verifyKind] is [PaystackVerifyKind.none]) before
/// navigating to [successRoute] — the redirect URL alone is never treated
/// as proof of payment.
class PaystackCheckoutScreen extends ConsumerStatefulWidget {
  final String authorizationUrl;
  final String? reference;
  final String? orderId;

  /// The payment attempt id returned by the initialize call, if available.
  final String? paymentAttemptId;

  /// Which server-side verify endpoint to call on redirect. Defaults to
  /// [PaystackVerifyKind.order].
  final PaystackVerifyKind verifyKind;

  /// The pay-link token to poll for [PaystackVerifyKind.payLink]. Kept
  /// separate from [orderId] since a pay-link token is not an order id.
  final String? payLinkToken;

  /// Optional override for the route to push on success.
  /// Defaults to [AppRoute.orderSuccess].
  final String? successRoute;

  /// Optional arguments passed to [successRoute].
  /// Defaults to `{'orderId': orderId, 'reference': reference}`.
  final Map<String, dynamic>? successArgs;

  const PaystackCheckoutScreen({
    super.key,
    required this.authorizationUrl,
    this.reference,
    this.orderId,
    this.paymentAttemptId,
    this.verifyKind = PaystackVerifyKind.order,
    this.payLinkToken,
    this.successRoute,
    this.successArgs,
  });

  @override
  ConsumerState<PaystackCheckoutScreen> createState() =>
      _PaystackCheckoutScreenState();
}

class _PaystackCheckoutScreenState
    extends ConsumerState<PaystackCheckoutScreen> {
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

            // Detect Paystack callback / success redirect.
            // Paystack appends ?trxref=...&reference=... to the callback URL.
            if (url.contains('trxref=') || url.contains('reference=')) {
              _onPaymentReturn(Uri.tryParse(url));
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.authorizationUrl));
  }

  Future<void> _onPaymentReturn(Uri? redirectUri) async {
    if (_isVerifying) return;

    final reference =
        redirectUri?.queryParameters['reference'] ??
        redirectUri?.queryParameters['trxref'] ??
        widget.reference;

    if (widget.verifyKind == PaystackVerifyKind.none ||
        widget.orderId == null ||
        reference == null) {
      _onVerifiedSuccess();
      return;
    }

    setState(() => _isVerifying = true);

    try {
      switch (widget.verifyKind) {
        case PaystackVerifyKind.order:
          final result = await ref
              .read(orderRepositoryProvider)
              .verifyPaystackPayment(
                VerifyPaystackPaymentRequest(
                  orderId: widget.orderId!,
                  reference: reference,
                ),
              );
          if (!mounted) return;
          if (result.verified) {
            _onVerifiedSuccess();
          } else {
            _showVerificationFailed();
          }
          break;
        case PaystackVerifyKind.parcel:
          final result = await ref
              .read(parcelRepositoryProvider)
              .verifyPaystackPayment(
                VerifyParcelPaystackPaymentRequest(
                  parcelId: widget.orderId!,
                  reference: reference,
                ),
              );
          if (!mounted) return;
          if (result.verified) {
            _onVerifiedSuccess();
          } else {
            _showVerificationFailed();
          }
          break;
        case PaystackVerifyKind.payLink:
          await _pollPayLinkStatus();
          break;
        case PaystackVerifyKind.none:
          _onVerifiedSuccess();
          break;
      }
    } on ApiException catch (e) {
      if (mounted) _showVerificationFailed(message: e.message);
    } catch (e) {
      if (mounted) _showVerificationFailed();
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  /// Polls `GET /pay-links/:token` until the backend's own computed status
  /// says the link is paid (or reaches a terminal non-paid state), rather
  /// than trusting the WebView's redirect URL alone.
  Future<void> _pollPayLinkStatus() async {
    final token = widget.payLinkToken;
    if (token == null) {
      _showVerificationFailed();
      return;
    }

    const maxAttempts = 8;
    const interval = Duration(seconds: 2);

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        final details = await ref
            .read(payLinkRepositoryProvider)
            .getPayLinkDetails(token);
        if (!mounted) return;
        if (details.status == 'PAID') {
          _onVerifiedSuccess();
          return;
        }
        if (details.status == 'CLOSED' ||
            details.status == 'EXPIRED' ||
            details.status == 'USED') {
          _showVerificationFailed(
            message: 'This payment link is ${details.status.toLowerCase()}.',
          );
          return;
        }
        // ACTIVE / RECOVERY_REQUIRED / anything else not yet confirmed —
        // keep polling; the webhook may still be catching up.
      } catch (_) {
        // Transient network error — keep retrying until attempts run out.
      }
      if (attempt < maxAttempts - 1) {
        await Future.delayed(interval);
        if (!mounted) return;
      }
    }

    if (!mounted) return;
    _showVerificationFailed(
      message:
          "We couldn't confirm your payment yet. Check back in a moment — it may still be processing.",
    );
  }

  void _showVerificationFailed({String? message}) {
    AppToast.showError(
      context,
      message ?? 'We could not confirm your payment. Please try again.',
    );
  }

  void _onVerifiedSuccess() {
    if (widget.verifyKind == PaystackVerifyKind.payLink) {
      // Pay-link payers aren't authenticated, so we never navigate into an
      // auth-gated route (order success/dashboard) here — pop back to
      // PayLinkScreen, which is safe for guests and already knows how to
      // show a paid state once it refreshes.
      Navigator.pop(context, true);
      return;
    }

    final route = widget.successRoute ?? AppRoute.orderSuccess;

    if (widget.orderId != null) {
      if (route == AppRoute.parcelTracking) {
        AppNotifications.parcelPlaced(widget.orderId!);
      } else {
        AppNotifications.orderPlaced(widget.orderId!);
      }
    }

    final args = widget.successArgs ??
        {'orderId': widget.orderId, 'reference': widget.reference};

    Navigator.pushNamedAndRemoveUntil(
      context,
      route,
      (r) => false,
      arguments: args,
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
          onPressed: _isVerifying ? null : _showCancelDialog,
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading || _isVerifying)
            Container(
              color: Colors.white.withValues(alpha: _isVerifying ? 0.85 : 1),
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
              Navigator.pop(context);
            },
            child: const AppText('Cancel', color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
