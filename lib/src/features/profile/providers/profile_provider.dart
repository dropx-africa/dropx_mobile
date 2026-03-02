import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/features/auth/providers/auth_providers.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/user_profile_response.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/update_profile_dto.dart';

class ProfileState {
  final UserProfileResponse? profile;

  const ProfileState({this.profile});

  ProfileState copyWith({UserProfileResponse? profile}) {
    return ProfileState(profile: profile ?? this.profile);
  }
}

class ProfileNotifier extends AsyncNotifier<ProfileState> {
  @override
  Future<ProfileState> build() async {
    final authRepo = ref.watch(authRepositoryProvider);
    UserProfileResponse? profile;

    try {
      profile = await authRepo.getProfile();
      debugPrint('[ProfileNotifier] Loaded profile: ${profile.toJson()}');
    } catch (e) {
      debugPrint('[ProfileNotifier] Error loading profile: $e');
    }

    return ProfileState(profile: profile);
  }

  Future<void> updateProfile(UpdateProfileDto dto) async {
    final authRepo = ref.read(authRepositoryProvider);
    final updatedProfile = await authRepo.updateProfile(dto);
    if (state.value != null) {
      state = AsyncData(state.value!.copyWith(profile: updatedProfile));
    } else {
      state = AsyncData(ProfileState(profile: updatedProfile));
    }
  }
}

final profileNotifierProvider =
    AsyncNotifierProvider<ProfileNotifier, ProfileState>(() {
      return ProfileNotifier();
    });
