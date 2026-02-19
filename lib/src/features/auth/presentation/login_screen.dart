import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/constants/app_icons.dart';
import 'package:dropx_mobile/src/common_widgets/custom_button.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/app_text_field.dart';
import 'package:dropx_mobile/src/common_widgets/app_spacers.dart';
import 'package:dropx_mobile/src/common_widgets/app_image.dart';
import 'package:dropx_mobile/src/route/page.dart';
import 'package:dropx_mobile/src/core/providers/core_providers.dart';
import 'package:dropx_mobile/src/core/network/api_client.dart';
import 'package:dropx_mobile/src/core/network/api_exceptions.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/login_dto.dart';
import 'package:dropx_mobile/src/features/auth/providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dto = LoginDto(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final authResponse = await ref.read(authRepositoryProvider).login(dto);

      // Save session
      final session = ref.read(sessionServiceProvider);
      await session.saveAuthSession(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
        userId: authResponse.userId,
      );

      // Set token on the API client
      ApiClient().setAuthToken(authResponse.accessToken);

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoute.manualLocation,
          (route) => false,
        );
      }
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const SizedBox.shrink(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                'Enter your email and password to login.',
                fontSize: 16,
              ),
              AppSpaces.v8,
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoute.signUp),
                child: const AppText(
                  "Don't have an account? Sign Up",
                  color: AppColors.primaryOrange,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              AppSpaces.v32,

              // Email Input
              AppTextField(
                label: 'Email',
                hintText: 'Enter your email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email is required';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim())) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              AppSpaces.v16,

              // Password Input
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              AppSpaces.v32,

              // Error message
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AppText(
                    _errorMessage!,
                    color: AppColors.errorRed,
                    fontSize: 12,
                  ),
                ),

              // Login Button
              CustomButton(
                text: _isLoading ? 'Logging in...' : 'Login',
                isLoading: _isLoading,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : const Icon(Icons.arrow_forward, color: AppColors.white),
                onPressed: _isLoading ? () {} : _handleLogin,
                backgroundColor: AppColors.darkBackground,
                textColor: AppColors.white,
              ),

              AppSpaces.v24,

              // Terms
              const Center(
                child: AppSubText(
                  "By continuing, you agree to our Terms & Privacy Policy.",
                  textAlign: TextAlign.center,
                  fontSize: 12,
                ),
              ),

              AppSpaces.v40,

              // Continue as Guest
              Center(
                child: TextButton(
                  onPressed: () async {
                    await ref.read(sessionServiceProvider).saveGuestMode();
                    if (context.mounted) {
                      Navigator.pushNamed(
                        context,
                        AppRoute.manualLocation,
                        arguments: {'isGuest': true},
                      );
                    }
                  },
                  child: const AppText(
                    "Continue as Guest",
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
