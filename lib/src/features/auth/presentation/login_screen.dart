import 'package:dropx_mobile/src/core/network/api_client.dart';
import 'package:dropx_mobile/src/utils/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/constants/app_icons.dart';
import 'package:dropx_mobile/src/common_widgets/custom_button.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/app_text_field.dart';
import 'package:dropx_mobile/src/common_widgets/app_spacers.dart';
import 'package:dropx_mobile/src/common_widgets/app_image.dart';
import 'package:dropx_mobile/src/common_widgets/app_scaffold.dart';
import 'package:dropx_mobile/src/route/page.dart';
import 'package:dropx_mobile/src/core/providers/core_providers.dart';
import 'package:dropx_mobile/src/core/network/api_exceptions.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/login_dto.dart';
import 'package:dropx_mobile/src/features/auth/providers/auth_providers.dart';
import 'package:dropx_mobile/src/common_widgets/app_toast.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Email tab
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
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
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_tabController.index == 0) {
      // Email login
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
      // Phone login
      if (_phoneNumber.length < 10) {
        AppToast.showError(context, 'Please enter a valid phone number');
        return;
      }
    }

    if (_passwordController.text.isEmpty) {
      AppToast.showError(context, 'Password is required');
      return;
    }
    if (_passwordController.text.length < 6) {
      AppToast.showError(context, 'Password must be at least 6 characters');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final dto = _tabController.index == 0
          ? LoginDto(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            )
          : LoginDto(
              phoneE164: _phoneNumber,
              password: _passwordController.text,
            );
      await _doLogin(dto);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _doLogin(LoginDto dto) async {
    try {
      final authResponse = await ref.read(authRepositoryProvider).login(dto);

      ApiClient().setAuthToken(
        authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );

      final session = ref.read(sessionServiceProvider);
      await session.saveAuthSession(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
        userId: authResponse.userId,
      );

      if (mounted) {
        AppToast.showSuccess(context, 'Welcome back!');
        if (!session.hasConfirmedLocation) {
          AppNavigator.pushReplacement(context, AppRoute.manualLocation);
        } else {
          AppNavigator.pushReplacement(context, AppRoute.dashboard);
        }
      }
    } on ApiException catch (e) {
      if (mounted) AppToast.showError(context, e.message);
    } catch (_) {
      if (mounted) {
        AppToast.showError(context, 'Something went wrong. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.white,
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
            const AppHeader('Welcome Back'),
            AppSpaces.v8,
            const AppSubText(
              'Login to your account to continue.',
              fontSize: 16,
            ),
            AppSpaces.v8,
            GestureDetector(
              onTap: () => AppNavigator.push(context, AppRoute.signUp),
              child: const AppText(
                "Don't have an account? Sign Up",
                color: AppColors.primaryOrange,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
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
            AppSpaces.v16,

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
            AppSpaces.v8,
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () =>
                    AppNavigator.push(context, AppRoute.forgotPassword),
                child: const AppText(
                  'Forgot Password?',
                  color: AppColors.primaryOrange,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            AppSpaces.v24,

            // Login button
            CustomButton(
              text: 'Login',
              isLoading: _isLoading,
              onPressed: _isLoading ? () {} : _handleLogin,
              backgroundColor: AppColors.darkBackground,
              textColor: AppColors.white,
            ),
            AppSpaces.v16,

            // Continue as Guest
            Center(
              child: GestureDetector(
                onTap: () async {
                  final session = ref.read(sessionServiceProvider);
                  await session.saveGuestMode();
                  if (mounted) {
                    AppNavigator.pushReplacement(
                      context,
                      AppRoute.manualLocation,
                    );
                  }
                },
                child: const AppText(
                  'Continue as Guest',
                  color: AppColors.primaryOrange,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            AppSpaces.v24,

            // Policy text
            const Center(
              child: AppSubText(
                "By continuing, you agree to our Terms & Privacy Policy.",
                textAlign: TextAlign.center,
                fontSize: 12,
              ),
            ),
      ],
    );
  }
}
