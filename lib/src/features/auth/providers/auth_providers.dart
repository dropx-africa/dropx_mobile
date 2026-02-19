import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/features/auth/data/auth_repository.dart';
import 'package:dropx_mobile/src/features/auth/data/remote_auth_repository.dart';
import 'package:dropx_mobile/src/core/providers/core_providers.dart';

/// ─── Repository Provider ──────────────────────────────────────
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return RemoteAuthRepository(ref.watch(apiClientProvider));
});

/// ─── State Providers ───────────────────────────────────────────

/// Whether the user is currently logged in (guest = false).
final isAuthenticatedProvider = FutureProvider<bool>((ref) {
  return ref.watch(authRepositoryProvider).isAuthenticated();
});
