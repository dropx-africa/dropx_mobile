import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/core/providers/core_providers.dart';
import 'package:dropx_mobile/src/features/profile/data/social_repository.dart';
import 'package:dropx_mobile/src/features/profile/data/remote_social_repository.dart';
import 'package:dropx_mobile/src/features/profile/data/dto/social_dto.dart';

final socialRepositoryProvider = Provider<SocialRepository>((ref) {
  return RemoteSocialRepository(ref.watch(apiClientProvider));
});

final socialFeedFutureProvider = FutureProvider<SocialFeedData>((ref) {
  return ref.watch(socialRepositoryProvider).getFeed();
});
