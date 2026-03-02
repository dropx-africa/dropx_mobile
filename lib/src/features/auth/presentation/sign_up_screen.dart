import 'package:dropx_mobile/src/utils/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/common_widgets/custom_button.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/app_text_field.dart';
import 'package:dropx_mobile/src/common_widgets/app_spacers.dart';
import 'package:dropx_mobile/src/core/network/api_client.dart';
import 'package:dropx_mobile/src/core/network/api_exceptions.dart';
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

  // Email tab fields
  final _emailFormKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _emailPhoneNumber = '';
  bool _isEmailLoading = false;
  bool _obscurePassword = true;

  // Phone tab fields
  final _phoneFormKey = GlobalKey<FormState>();
  String _phoneNumber = '';
  bool _isPhoneLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Email Sign Up ─────────────────────────────────────────────
  Future<void> _signUpWithEmail() async {
    if (!_emailFormKey.currentState!.validate()) return;
    if (_emailPhoneNumber.length < 10) {
      AppToast.showError(context, 'Please enter a valid phone number');
      return;
    }

    setState(() => _isEmailLoading = true);

    try {
      final dto = RegisterDto(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneE164: _emailPhoneNumber,
        password: _passwordController.text,
        role: 'customer',
      );

      if (kDebugMode) {
        print('[SignUp] DTO payload: ${dto.toJson()}');
      }

      final authResponse = await ref.read(authRepositoryProvider).register(dto);
      if (kDebugMode) {
        print('[SignUp] Success — userId: ${authResponse.userId}');
      }

      final session = ref.read(sessionServiceProvider);
      await session.saveAuthSession(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
        userId: authResponse.userId,
        fullName: _fullNameController.text.trim(),
        phone: _emailPhoneNumber,
      );

      ApiClient().setAuthToken(
        authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );

      if (mounted) {
        AppToast.showSuccess(context, 'Account created successfully!');
        AppNavigator.pushReplacement(context, AppRoute.manualLocation);
      }
    } on ApiException catch (e) {
      if (kDebugMode) print('[SignUp] ApiException: ${e.message}');
      if (mounted) AppToast.showError(context, e.message);
    } catch (e) {
      if (kDebugMode) print('[SignUp] Unexpected error: $e');
      if (mounted) {
        AppToast.showError(context, 'Something went wrong. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isEmailLoading = false);
    }
  }

  // ── Phone Sign Up (OTP) ───────────────────────────────────────
  Future<void> _signUpWithPhone() async {
    if (_phoneNumber.length < 10) {
      AppToast.showError(context, 'Please enter a valid phone number');
      return;
    }

    setState(() => _isPhoneLoading = true);

    try {
      final dto = OtpRequestDto(phoneE164: _phoneNumber);

      if (kDebugMode) {
        print('[SignUp] OTP request payload: ${dto.toJson()}');
      }

      final challenge = await ref.read(authRepositoryProvider).requestOtp(dto);

      if (kDebugMode) {
        print('[SignUp] OTP sent — challengeId: ${challenge.otpChallengeId}');
      }

      if (mounted) {
        AppToast.showSuccess(context, 'OTP sent to $_phoneNumber');
        AppNavigator.push(
          context,
          AppRoute.otp,
          arguments: {
            'phoneNumber': _phoneNumber,
            'otpChallengeId': challenge.otpChallengeId,
            'nextResendAt': challenge.nextResendAt,
            'attemptsRemaining': challenge.attemptsRemaining,
          },
        );
      }
    } on ApiException catch (e) {
      if (kDebugMode) print('[SignUp] OTP ApiException: ${e.message}');
      if (mounted) AppToast.showError(context, e.message);
    } catch (e) {
      if (kDebugMode) print('[SignUp] OTP Unexpected error: $e');
      if (mounted) {
        AppToast.showError(context, 'Something went wrong. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isPhoneLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: AppColors.black),
        title: const AppHeader('Create Account'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
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
              ],
            ),
          ),
          AppSpaces.v24,

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildEmailTab(), _buildPhoneTab()],
            ),
          ),
        ],
      ),
    );
  }

  // ── Email Tab ─────────────────────────────────────────────────
  Widget _buildEmailTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Form(
        key: _emailFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Full Name
            AppTextField(
              label: 'Full Name',
              hintText: 'Enter your full name',
              controller: _fullNameController,
              validator: (val) =>
                  val == null || val.isEmpty ? 'Full Name is Required' : null,
            ),
            AppSpaces.v16,

            // Email
            AppTextField(
              label: 'Email Address',
              hintText: 'eg example@gmail.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Email Address is Required';
                }
                if (!val.contains('@')) return 'Invalid email';
                return null;
              },
            ),
            AppSpaces.v16,

            // Phone
            AppTextField(
              isPhone: true,
              hintText: 'Enter your phone number',
              label: 'Phone Number',
              onPhoneChanged: (phone) {
                _emailPhoneNumber = phone.completeNumber;
              },
            ),
            AppSpaces.v16,

            // Password
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
              validator: (val) {
                if (val == null || val.isEmpty) return 'Password is Required';
                if (val.length < 6) return 'Min 6 characters';
                return null;
              },
            ),
            AppSpaces.v32,

            CustomButton(
              text: 'Sign Up',
              isLoading: _isEmailLoading,
              onPressed: _isEmailLoading ? () {} : _signUpWithEmail,
              backgroundColor: AppColors.primaryOrange,
              textColor: AppColors.white,
            ),

            AppSpaces.v24,
            _buildLoginLink(),
          ],
        ),
      ),
    );
  }

  // ── Phone Tab ─────────────────────────────────────────────────
  Widget _buildPhoneTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Form(
        key: _phoneFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppSubText(
              'We\'ll send you a verification code via SMS to create your account.',
              fontSize: 14,
            ),
            AppSpaces.v24,

            // Phone
            AppTextField(
              isPhone: true,
              hintText: 'Enter your phone number',
              label: 'Phone Number',
              onPhoneChanged: (phone) {
                _phoneNumber = phone.completeNumber;
              },
            ),
            AppSpaces.v32,

            CustomButton(
              text: 'Continue',
              isLoading: _isPhoneLoading,
              onPressed: _isPhoneLoading ? () {} : _signUpWithPhone,
              backgroundColor: AppColors.primaryOrange,
              textColor: AppColors.white,
            ),

            AppSpaces.v24,
            _buildLoginLink(),
          ],
        ),
      ),
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
