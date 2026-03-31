import 'package:dropx_mobile/src/utils/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/utils/app_log.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/common_widgets/custom_button.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/app_text_field.dart';
import 'package:dropx_mobile/src/common_widgets/app_spacers.dart';
import 'package:dropx_mobile/src/common_widgets/app_scaffold.dart';
import 'package:dropx_mobile/src/common_widgets/app_appbar.dart';
import 'package:dropx_mobile/src/core/network/api_client.dart';
import 'package:dropx_mobile/src/core/network/api_exceptions.dart';
import 'package:dropx_mobile/src/core/utils/validators.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/register_dto.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/otp_request_dto.dart';
import 'package:dropx_mobile/src/features/auth/providers/auth_providers.dart';
import 'package:dropx_mobile/src/route/page.dart';
import 'package:dropx_mobile/src/core/providers/core_providers.dart';
import 'package:dropx_mobile/src/common_widgets/app_toast.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Shared fields
  final _fullNameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  // Email tab fields
  final _emailController = TextEditingController();

  // Single phone number for both tabs
  final _phoneController = TextEditingController();

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
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    // Validate full name
    if (_fullNameController.text.trim().isEmpty) {
      AppToast.showError(context, 'Full Name is Required');
      return;
    }

    // Validate password
    final passwordError = Validators.password(_passwordController.text);
    if (passwordError != null) {
      AppToast.showError(context, passwordError);
      return;
    }

    // Validate contact info based on tab
    final email = _emailController.text.trim();
    final hasEmail = email.isNotEmpty;
    final hasPhone = _phoneController.text.length >= 10;

    if (!hasEmail && !hasPhone) {
      AppToast.showError(context, 'Please provide an email or phone number');
      return;
    }

    if (hasEmail && !email.contains('@')) {
      AppToast.showError(context, 'Invalid email address');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dto = RegisterDto(
        fullName: _fullNameController.text.trim(),
        email: hasEmail ? email : null,
        phoneE164: hasPhone ? _phoneController.text : null,
        password: _passwordController.text,
        role: 'customer',
      );

      AppLog.d('[SignUp] DTO payload: ${dto.toJson()}');

      final authResponse = await ref.read(authRepositoryProvider).register(dto);
      AppLog.d('[SignUp] Success — userId: ${authResponse.userId}');

      // Request OTP — prefer phone (SMS) when provided, fall back to email.
      final otpDto = OtpRequestDto(
        email: hasEmail ? email : null,
        phoneE164: hasPhone ? _phoneController.text : null,
        purpose: 'REGISTER',
        channel: hasPhone ? 'sms' : 'email',
      );
      final challenge = await ref
          .read(authRepositoryProvider)
          .requestOtp(otpDto);

      AppLog.d('[SignUp] OTP sent — challengeId: ${challenge.otpChallengeId}');

      final sentTo = hasPhone ? _phoneController.text : email;

      if (mounted) {
        AppToast.showSuccess(
          context,
          'Verify your ${hasPhone ? 'phone' : 'email'} to continue',
        );
        AppNavigator.pushReplacement(
          context,
          AppRoute.otp,
          arguments: {
            'sentTo': sentTo,
            'channel': challenge.channel,
            'otpChallengeId': challenge.otpChallengeId,
            'resendAvailableAt': challenge.resendAvailableAt,
          },
        );
      }
    } on ApiException catch (e) {
      AppLog.e('[SignUp] ApiException', e.message);
      if (mounted) AppToast.showError(context, e.message);
    } catch (e) {
      AppLog.e('[SignUp] Unexpected error', e.toString());
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
      backgroundColor: AppColors.white,
      appBar: const AppAppBar(
        title: 'Create Account',
        style: AppAppBarStyle.white,
      ),
      children: [
        const AppSubText(
          'Sign up to get started with DropX.',
          textAlign: TextAlign.center,
        ),
        AppSpaces.v24,

        // Tab Bar
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

        // Full Name (shared)
        AppTextField(
          label: 'Full Name',
          hintText: 'Enter your full name',
          controller: _fullNameController,
        ),
        AppSpaces.v16,

        // Contact field (changes based on tab)
        _tabController.index == 0
            ? AppTextField(
                label: 'Email Address',
                hintText: 'eg example@gmail.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              )
            : AppTextField(
                isPhone: true,
                label: 'Phone Number',
                hintText: 'Enter your phone number',
                controller: _phoneController,
                onPhoneChanged: (phone) {
                  setState(() {});
                },
              ),
        AppSpaces.v16,

        // Phone field (optional in email tab)
        if (_tabController.index == 0) ...[
          AppTextField(
            isPhone: true,
            label: 'Phone Number (Optional)',
            hintText: 'Enter your phone number',
            controller: _phoneController,
            onPhoneChanged: (phone) {
              setState(() {});
            },
          ),
          AppSpaces.v16,
        ],

        // Password field (shared)
        AppTextField(
          label: 'Password',
          hintText: 'Enter your password',
          controller: _passwordController,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: AppColors.slate500,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        AppSpaces.v32,

        // Sign Up button
        CustomButton(
          text: 'Sign Up',
          isLoading: _isLoading,
          onPressed: _isLoading ? () {} : _handleSignUp,
          backgroundColor: AppColors.primaryOrange,
          textColor: AppColors.white,
        ),

        AppSpaces.v24,
        _buildLoginLink(),
      ],
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const AppSubText('Already have an account? '),
        GestureDetector(
          onTap: () => AppNavigator.pop(context),
          child: const AppText(
            'Login',
            color: AppColors.primaryOrange,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
