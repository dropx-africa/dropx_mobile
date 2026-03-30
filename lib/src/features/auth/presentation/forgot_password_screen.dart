import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/constants/app_icons.dart';
import 'package:dropx_mobile/src/common_widgets/custom_button.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/app_text_field.dart';
import 'package:dropx_mobile/src/common_widgets/app_spacers.dart';
import 'package:dropx_mobile/src/common_widgets/app_image.dart';
import 'package:dropx_mobile/src/common_widgets/app_toast.dart';
import 'package:dropx_mobile/src/common_widgets/app_scaffold.dart';
import 'package:dropx_mobile/src/common_widgets/app_appbar.dart';
import 'package:dropx_mobile/src/route/page.dart';
import 'package:dropx_mobile/src/utils/app_navigator.dart';
import 'package:dropx_mobile/src/core/network/api_exceptions.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/otp_request_dto.dart';
import 'package:dropx_mobile/src/features/auth/providers/auth_providers.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Email tab
  final _emailController = TextEditingController();
  String _phoneNumber = '';

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    // Validate contact info based on tab
    if (_tabController.index == 0) {
      // Email
      if (_emailController.text.trim().isEmpty) {
        AppToast.showError(context, 'Email is required');
        return;
      }
      if (!RegExp(
        r'^[^@]+@[^@]+\.[^@]+',
      ).hasMatch(_emailController.text.trim())) {
        AppToast.showError(context, 'Enter a valid email');
        return;
      }
    } else {
      // Phone
      if (_phoneNumber.length < 10) {
        AppToast.showError(context, 'Please enter a valid phone number');
        return;
      }
    }

    setState(() => _isLoading = true);
    try {
      final dto = _tabController.index == 0
          ? OtpRequestDto(email: _emailController.text.trim())
          : OtpRequestDto(phoneE164: _phoneNumber);
      final challenge = await ref.read(authRepositoryProvider).requestOtp(dto);

      if (mounted) {
        AppToast.showSuccess(
          context,
          'OTP sent to your ${_tabController.index == 0 ? 'email' : 'phone'}',
        );
        AppNavigator.pushReplacement(
          context,
          AppRoute.otp,
          arguments: {
            'sentTo': _tabController.index == 0
                ? _emailController.text.trim()
                : _phoneNumber,
            'channel': _tabController.index == 0 ? 'email' : 'sms',
            'otpChallengeId': challenge.otpChallengeId,
            'resendAvailableAt': challenge.resendAvailableAt,
            'isForgotPassword': true,
          },
        );
      }
    } on ApiException catch (e) {
      if (mounted) AppToast.showError(context, e.message);
    } catch (_) {
      if (mounted) {
        AppToast.showError(context, 'Something went wrong. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppAppBar(
        title: 'Forgot Password',
        style: AppAppBarStyle.white,
      ),
      children: [
        Center(
          child: Column(
            children: [
              const AppImage(AppIcon.logo2, height: 60),
              AppSpaces.v8,
              const AppSubText(
                "No Stories. Just Delivery.",
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        AppSpaces.v48,
        const AppHeader('Forgot Password'),
        AppSpaces.v8,
        const AppSubText(
          'Enter your email or phone number to receive a verification code.',
          fontSize: 16,
        ),
        AppSpaces.v24,

        // Tab bar
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF4F6F8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          padding: const EdgeInsets.all(6),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: AppColors.primaryOrange,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryOrange.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelColor: Colors.white,
            unselectedLabelColor: AppColors.slate500,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
            tabs: const [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.email_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Email'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.phone_android_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Phone'),
                  ],
                ),
              ),
            ],
          ),
        ),
        AppSpaces.v24,

        // Contact field (changes based on tab)
        _tabController.index == 0
            ? AppTextField(
                label: 'Email',
                hintText: 'Enter your email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              )
            : AppTextField(
                isPhone: true,
                label: 'Phone Number',
                hintText: 'Enter your phone number',
                onPhoneChanged: (phone) {
                  _phoneNumber = phone.completeNumber;
                },
              ),
        AppSpaces.v32,

        // Send OTP button
        CustomButton(
          text: 'Send OTP',
          isLoading: _isLoading,
          onPressed: _isLoading ? () {} : _handleSubmit,
          backgroundColor: AppColors.darkBackground,
          textColor: AppColors.white,
        ),
        AppSpaces.v24,
        Center(
          child: GestureDetector(
            onTap: () => AppNavigator.pushReplacement(context, AppRoute.login),
            child: const AppText(
              'Back to Login',
              color: AppColors.primaryOrange,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        AppSpaces.v24,
      ],
    );
  }
}
