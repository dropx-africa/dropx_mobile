import 'package:flutter/material.dart';
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
  String? _errorMessage;

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
      setState(() => _errorMessage = 'Please enter a valid phone number');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dto = RegisterDto(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneE164:
            _phoneNumber, // Ensure format matches backend expectation (e.g. +234...)
        password: _passwordController.text,
        role: 'user', // Default role
      );

      final authResponse = await ref.read(authRepositoryProvider).register(dto);

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
        leading: BackButton(color: AppColors.black),
        title: const AppHeader('Create Account'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AppSubText(
                  'Sign up to get started with DropX.',
                  textAlign: TextAlign.center,
                ),
                AppSpaces.v32,

                // Full Name
                AppTextField(
                  label: 'Full Name',
                  controller: _fullNameController,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),
                AppSpaces.v16,

                // Email
                AppTextField(
                  label: 'Email Address',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Required';
                    if (!val.contains('@')) return 'Invalid email';
                    return null;
                  },
                ),
                AppSpaces.v16,

                // Phone
                AppTextField(
                  isPhone: true,
                  label: 'Phone Number',
                  onPhoneChanged: (phone) {
                    _phoneNumber = phone.completeNumber;
                  },
                ),
                AppSpaces.v16,

                // Password
                AppTextField(
                  label: 'Password',
                  controller: _passwordController,
                  obscureText: true,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Required';
                    if (val.length < 6) return 'Min 6 characters';
                    return null;
                  },
                ),
                AppSpaces.v32,

                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: AppText(
                      _errorMessage!,
                      color: AppColors.errorRed,
                      textAlign: TextAlign.center,
                    ),
                  ),

                CustomButton(
                  text: 'Sign Up',
                  isLoading: _isLoading,
                  onPressed: _isLoading ? () {} : _signUp,
                  backgroundColor: AppColors.primaryOrange,
                  textColor: Colors.white,
                ),

                AppSpaces.v24,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const AppSubText('Already have an account? '),
                    GestureDetector(
                      onTap: () => Navigator.pop(context), // Go back to Login
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
      ),
    );
  }
}
