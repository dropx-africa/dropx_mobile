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
import 'package:dropx_mobile/src/features/auth/providers/auth_providers.dart';
import 'package:dropx_mobile/src/route/page.dart';
import 'package:dropx_mobile/src/core/providers/core_providers.dart';
import 'package:dropx_mobile/src/common_widgets/app_toast.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _phoneNumber = '';

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (_phoneNumber.length < 10) {
      AppToast.showError(context, 'Please enter a valid phone number');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final dto = RegisterDto(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneE164:
            _phoneNumber, // Ensure format matches backend expectation (e.g. +234...)
        password: _passwordController.text,
        role: 'customer', // Default role
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
        phone: _phoneNumber,
      );

      // Set token on the API client for all subsequent requests
      ApiClient().setAuthToken(authResponse.accessToken);

      if (mounted) {
        AppToast.showSuccess(context, 'Account created successfully!');
        AppNavigator.pushReplacement(context, AppRoute.manualLocation);
      }
    } on ApiException catch (e, st) {
      if (kDebugMode) {
        print('[SignUp] ApiException: ${e.message}');
        print('[SignUp] ApiException statusCode: ${e.statusCode}');
        print('[SignUp] ApiException stack: $st');
      }
      if (mounted) AppToast.showError(context, e.message);
    } catch (e, st) {
      if (kDebugMode) {
        print('[SignUp] Unexpected error: $e');
        print('[SignUp] Unexpected error type: ${e.runtimeType}');
        print('[SignUp] Stack trace: $st');
      }
      if (mounted) {
        AppToast.showError(context, 'Something went wrong. Please try again.');
      }
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
        leading: BackButton(color: AppColors.black),
        title: const AppHeader('Create Account'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppSubText(
                'Sign up to get started with DropX.',
                textAlign: TextAlign.center,
              ),
              AppSpaces.v32,

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

                  if (!val.contains('@')) {
                    return 'Invalid email';
                  }
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
                  _phoneNumber = phone.completeNumber;
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
                isLoading: _isLoading,
                onPressed: _isLoading ? () {} : _signUp,
                backgroundColor: AppColors.primaryOrange,
                textColor: AppColors.white,
              ),

              AppSpaces.v24,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppSubText('Already have an account? '),
                  GestureDetector(
                    onTap: () => AppNavigator.pop(context), // Go back to Login
                    child: const AppText(
                      'Login',
                      color: AppColors.primaryOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
