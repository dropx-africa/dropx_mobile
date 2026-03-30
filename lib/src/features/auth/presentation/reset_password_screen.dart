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
import 'package:dropx_mobile/src/route/page.dart';
import 'package:dropx_mobile/src/utils/app_navigator.dart';
import 'package:dropx_mobile/src/core/network/api_client.dart';
import 'package:dropx_mobile/src/core/network/api_exceptions.dart';
import 'package:dropx_mobile/src/features/auth/providers/auth_providers.dart';
import 'package:dropx_mobile/src/core/providers/core_providers.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String otpChallengeId;
  final String otp;

  const ResetPasswordScreen({
    super.key,
    required this.otpChallengeId,
    required this.otp,
  });

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Call reset password API
      final response = await ref
          .read(authRepositoryProvider)
          .resetPassword(
            otpChallengeId: widget.otpChallengeId,
            otp: widget.otp,
            newPassword: _passwordController.text,
          );

      // Set auth tokens
      ApiClient().setAuthToken(
        response.accessToken,
        refreshToken: response.refreshToken,
      );

      // Save session
      final session = ref.read(sessionServiceProvider);
      await session.saveAuthSession(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        userId: response.userId,
      );

      if (mounted) {
        AppToast.showSuccess(context, 'Password reset successfully!');
        AppNavigator.pushReplacement(context, AppRoute.login);
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
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: AppColors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
            const AppHeader('Reset Password'),
            AppSpaces.v8,
            const AppSubText('Enter your new password below.', fontSize: 16),
            AppSpaces.v32,
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    label: 'New Password',
                    hintText: 'Enter your new password',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.slate500,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Password is required';
                      }
                      if (v.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  AppSpaces.v16,
                  AppTextField(
                    label: 'Confirm Password',
                    hintText: 'Confirm your new password',
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.slate500,
                      ),
                      onPressed: () => setState(
                        () =>
                            _obscureConfirmPassword = !_obscureConfirmPassword,
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (v != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  AppSpaces.v32,
                  CustomButton(
                    text: 'Reset Password',
                    isLoading: _isLoading,
                    onPressed: _isLoading ? () {} : _handleResetPassword,
                    backgroundColor: AppColors.darkBackground,
                    textColor: AppColors.white,
                  ),
                  AppSpaces.v24,
                  Center(
                    child: GestureDetector(
                      onTap: () =>
                          AppNavigator.pushReplacement(context, AppRoute.login),
                      child: const AppText(
                        'Back to Login',
                        color: AppColors.primaryOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
