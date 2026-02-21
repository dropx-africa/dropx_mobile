import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/app_text_field.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/features/paylink/providers/paylink_providers.dart';
import 'package:dropx_mobile/src/features/paylink/data/dto/initialize_pay_link_dto.dart';
import 'package:dropx_mobile/src/route/page.dart';

class PayLinkScreen extends ConsumerStatefulWidget {
  final String token;

  const PayLinkScreen({super.key, required this.token});

  @override
  ConsumerState<PayLinkScreen> createState() => _PayLinkScreenState();
}

class _PayLinkScreenState extends ConsumerState<PayLinkScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isInitializing = false;
  String? _errorMessage;
  String? _amountNaira;
  String? _status;

  @override
  void initState() {
    super.initState();
    _fetchLinkDetails();
  }

  Future<void> _fetchLinkDetails() async {
    try {
      final repo = ref.read(payLinkRepositoryProvider);
      final response = await repo.getPayLinkDetails(widget.token);

      setState(() {
        _amountNaira = (int.parse(response.amountKobo) / 100).toStringAsFixed(
          2,
        );
        _status = response.status;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            "Failed to load payment link. It may be expired or invalid.";
        _isLoading = false;
      });
    }
  }

  Future<void> _initializePayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isInitializing = true);

    try {
      final repo = ref.read(payLinkRepositoryProvider);
      final response = await repo.initializePayLink(
        widget.token,
        InitializePayLinkDto(
          provider: 'paystack',
          payerEmail: _emailController.text,
        ),
      );

      if (!mounted) return;

      // Navigate to checkout webview
      Navigator.pushReplacementNamed(
        context,
        AppRoute.paystackCheckout,
        arguments: {
          'authorizationUrl': response.authorizationUrl,
          'reference': response.reference,
          'orderId': widget
              .token, // Token logic could vary for orderId callback validation
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification Failed: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isInitializing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const AppText(
          "Payment Link",
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryOrange),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.errorRed,
              ),
              const SizedBox(height: 16),
              AppText(
                _errorMessage!,
                textAlign: TextAlign.center,
                fontSize: 16,
              ),
            ],
          ),
        ),
      );
    }

    if (_status != 'ACTIVE') {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.close, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              AppText(
                "This payment link is $_status.",
                textAlign: TextAlign.center,
                fontSize: 16,
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  AppText(
                    "Amount Due",
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                  const SizedBox(height: 8),
                  AppText(
                    '₦$_amountNaira',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryOrange,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            AppText(
              "Enter your email to continue",
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
            const SizedBox(height: 8),
            AppTextField(
              controller: _emailController,
              hintText: "Email Address",
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.email_outlined),
              validator: (value) {
                if (value == null || value.isEmpty || !value.contains('@')) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isInitializing ? null : _initializePayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isInitializing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const AppText(
                      "Proceed to Pay",
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
