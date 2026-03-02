import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/features/auth/providers/auth_providers.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/user_preferences_response.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/update_preferences_dto.dart';

class PreferencesNotifier extends AsyncNotifier<UserPreferencesResponse?> {
  @override
  Future<UserPreferencesResponse?> build() async {
    final authRepo = ref.watch(authRepositoryProvider);
    try {
      final prefs = await authRepo.getPreferences();
      debugPrint('[PreferencesNotifier] Loaded preferences: ${prefs.toJson()}');
      return prefs;
    } catch (e) {
      debugPrint('[PreferencesNotifier] Error loading preferences: $e');
      return null;
    }
  }

  Future<void> updatePreferences(UpdatePreferencesDto dto) async {
    final authRepo = ref.read(authRepositoryProvider);
    try {
      final updatedPrefs = await authRepo.updatePreferences(dto);
      state = AsyncData(updatedPrefs);
    } catch (e) {
      debugPrint('[PreferencesNotifier] Error updating preferences: $e');
      rethrow;
    }
  }
}

final preferencesNotifierProvider =
    AsyncNotifierProvider<PreferencesNotifier, UserPreferencesResponse?>(() {
      return PreferencesNotifier();
    });
