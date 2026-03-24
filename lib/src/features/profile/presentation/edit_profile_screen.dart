import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/app_text_field.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/features/profile/providers/profile_provider.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/update_profile_dto.dart';
import 'package:dropx_mobile/src/core/utils/cloudinary_upload.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _phoneE164 = '';
  String? _avatarUrl;
  File? _localAvatarFile;
  bool _isUploadingAvatar = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentProfile();
    });
  }

  void _loadCurrentProfile() {
    final profileState = ref.read(profileNotifierProvider);
    final userProfile = profileState.value?.profile;

    _nameController.text = userProfile?.fullName ?? '';

    String phone = userProfile?.phone ?? '';

    if (phone.startsWith('+234')) {
      _phoneController.text = phone.substring(4);
    } else {
      _phoneController.text = phone;
    }
    _phoneE164 = phone;
    setState(() {
      _avatarUrl = userProfile?.avatarUrl;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
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
          throw Exception(
            "Failed to upload profile picture. Please try again.",
          );
        }
      }

      String phoneToSave = _phoneE164.isNotEmpty
          ? _phoneE164
          : _phoneController.text.trim();
      if (phoneToSave.isNotEmpty && !phoneToSave.startsWith('+')) {
        if (phoneToSave.startsWith('0')) {
          phoneToSave = '+234${phoneToSave.substring(1)}';
        } else {
          phoneToSave = '+234$phoneToSave';
        }
      }

      final dto = UpdateProfileDto(
        fullName: _nameController.text.trim(),
        phoneE164: phoneToSave,
        avatarUrl: finalAvatarUrl,
      );

      await ref.read(profileNotifierProvider.notifier).updateProfile(dto);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
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
      _avatarUrl = null; // Clear remote URL since we have a new local file
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const AppText(
          "Edit Profile",
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                          image:
                              (_localAvatarFile != null || _avatarUrl != null)
                              ? DecorationImage(
                                  image: _localAvatarFile != null
                                      ? FileImage(_localAvatarFile!)
                                      : NetworkImage(_avatarUrl!)
                                            as ImageProvider,
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: (_localAvatarFile == null && _avatarUrl == null)
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
                            border: Border.all(color: Colors.white, width: 2),
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
              const AppText(
                "Full Name",
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              const SizedBox(height: 8),
              AppTextField(
                controller: _nameController,
                hintText: "Enter your full name",
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return "Name cannot be empty";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const AppText(
                "Phone Number",
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              const SizedBox(height: 8),
              AppTextField(
                isPhone: true,
                controller: _phoneController,
                hintText: "e.g 8012345678",
                onPhoneChanged: (phone) {
                  _phoneE164 = phone.completeNumber;
                },
              ),
              const SizedBox(height: 48),
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
                          "Save Changes",
                          color: Colors.white,
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
