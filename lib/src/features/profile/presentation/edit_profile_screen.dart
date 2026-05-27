import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/app_text_field.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/features/profile/providers/profile_provider.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/update_profile_dto.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/user_profile_response.dart';
import 'package:dropx_mobile/src/core/utils/cloudinary_upload.dart';
import 'package:dropx_mobile/src/core/providers/core_providers.dart';
import 'package:dropx_mobile/src/utils/app_navigator.dart';
import 'package:dropx_mobile/src/common_widgets/app_toast.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneLocalController = TextEditingController();
  String _phoneE164 = '';
  String? _avatarUrl;
  File? _localAvatarFile;
  bool _isUploadingAvatar = false;
  bool _isLoading = false;
  bool _controllersPopulated = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneLocalController.dispose();
    super.dispose();
  }

  void _populateControllers(UserProfileResponse profile) {
    if (_controllersPopulated) return;
    _nameController.text = profile.fullName ?? '';
    _emailController.text = profile.email ?? '';
    final stored = profile.phone ?? '';
    _phoneE164 = stored;
    if (stored.startsWith('+234')) {
      _phoneLocalController.text = stored.substring(4);
    } else if (stored.startsWith('234')) {
      _phoneLocalController.text = stored.substring(3);
    } else {
      _phoneLocalController.text = stored;
    }
    final session = ref.read(sessionServiceProvider);
    debugPrint('[EditProfile] _populateControllers → '
        'api.fullName="${profile.fullName}" '
        'api.phone="${profile.phone}" '
        'session.fullName="${session.fullName}" '
        'session.phone="${session.phone}" '
        'loginMethod="${session.loginMethod}"');
    setState(() {
      _controllersPopulated = true;
      _avatarUrl = profile.avatarUrl;
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String? finalAvatarUrl = _avatarUrl;
      if (_localAvatarFile != null) {
        final uploadedUrl = await CloudinaryUploadService.uploadImage(
          _localAvatarFile!,
        );
        if (uploadedUrl != null) {
          finalAvatarUrl = uploadedUrl;
        } else {
          throw Exception('Failed to upload profile picture. Please try again.');
        }
      }

      final dto = UpdateProfileDto(
        fullName: _nameController.text.trim().isEmpty
            ? null
            : _nameController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        phoneE164: _phoneE164.isEmpty ? null : _phoneE164,
        avatarUrl: finalAvatarUrl,
      );

      debugPrint('[EditProfile] _saveProfile → '
          'dto.fullName="${dto.fullName}" '
          'dto.phoneE164="${dto.phoneE164}" '
          '_phoneE164="$_phoneE164" '
          'nameController="${_nameController.text}"');

      await ref.read(profileNotifierProvider.notifier).updateProfile(dto);

      // Use the server-confirmed profile values so partial DTOs still capture
      // what the backend actually stored.
      final saved = ref.read(profileNotifierProvider).value?.profile;
      final session = ref.read(sessionServiceProvider);
      await session.saveAuthSession(
        fullName: saved?.fullName,
        phone: saved?.phone,
      );

      debugPrint('[EditProfile] after saveAuthSession → '
          'session.fullName="${session.fullName}" '
          'session.phone="${session.phone}"');

      if (mounted) {
        AppToast.showSuccess(context, 'Profile updated successfully');
        AppNavigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Failed to update profile: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;
    setState(() {
      _localAvatarFile = File(pickedFile.path);
      _avatarUrl = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Populate controllers the first time the profile data becomes available.
    ref.listen<AsyncValue<ProfileState>>(profileNotifierProvider, (_, next) {
      final profile = next.value?.profile;
      if (profile != null) _populateControllers(profile);
    });

    final profileAsync = ref.watch(profileNotifierProvider);
    final bool isProfileLoading =
        profileAsync.isLoading && !_controllersPopulated;

    // Also populate immediately if data is already in the cache on first build.
    if (!_controllersPopulated) {
      final profile = profileAsync.value?.profile;
      if (profile != null) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _populateControllers(profile),
        );
      }
    }

    final session = ref.read(sessionServiceProvider);
    final isEmailLogin = session.loginMethod == 'email';
    final isPhoneLogin = session.loginMethod == 'phone';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const AppText(
          'Edit Profile',
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
      ),
      body: isProfileLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryOrange,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Avatar ──────────────────────────────────────────────
                    Center(
                      child: GestureDetector(
                        onTap: _isUploadingAvatar ? null : _pickAndUploadImage,
                        child: Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.slate100,
                                border: Border.all(
                                  color: AppColors.primaryOrange,
                                  width: 2,
                                ),
                                image: (_localAvatarFile != null ||
                                        _avatarUrl != null)
                                    ? DecorationImage(
                                        image: _localAvatarFile != null
                                            ? FileImage(_localAvatarFile!)
                                            : NetworkImage(_avatarUrl!)
                                                as ImageProvider,
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child:
                                  (_localAvatarFile == null &&
                                          _avatarUrl == null)
                                      ? const Center(
                                          child: Icon(
                                            Icons.person,
                                            size: 50,
                                            color: AppColors.slate400,
                                          ),
                                        )
                                      : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryOrange,
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Full Name ────────────────────────────────────────────
                    const AppText(
                      'Full Name',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    const SizedBox(height: 8),
                    AppTextField(
                      controller: _nameController,
                      hintText: 'Enter your full name',
                      prefixIcon: const Icon(
                        Icons.person_outline,
                        color: AppColors.slate400,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Email ────────────────────────────────────────────────
                    const AppText(
                      'Email Address',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    const SizedBox(height: 8),
                    AppTextField(
                      controller: _emailController,
                      hintText: 'Enter your email address',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: AppColors.slate400,
                      ),
                      readOnly: isEmailLogin,
                      validator: isEmailLogin
                          ? null
                          : (val) {
                              if (val == null || val.trim().isEmpty) return null;
                              final emailRegex =
                                  RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                              if (!emailRegex.hasMatch(val.trim())) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                    ),
                    if (isEmailLogin) ...[
                      const SizedBox(height: 6),
                      const AppText(
                        'This is your login email. Contact support to change it.',
                        fontSize: 12,
                        color: AppColors.slate400,
                      ),
                    ],
                    const SizedBox(height: 20),

                    // ── Phone ────────────────────────────────────────────────
                    AppTextField(
                      isPhone: true,
                      label: 'Phone Number',
                      hintText: 'Enter your phone number',
                      controller: _phoneLocalController,
                      readOnly: isPhoneLogin,
                      onPhoneChanged: isPhoneLogin
                          ? null
                          : (phone) =>
                              setState(() => _phoneE164 = phone.completeNumber),
                    ),
                    if (isPhoneLogin) ...[
                      const SizedBox(height: 6),
                      const AppText(
                        'This is your login phone number. Contact support to change it.',
                        fontSize: 12,
                        color: AppColors.slate400,
                      ),
                    ],
                    const SizedBox(height: 48),

                    // ── Save ─────────────────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryOrange,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const AppText(
                                'Save Changes',
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}
