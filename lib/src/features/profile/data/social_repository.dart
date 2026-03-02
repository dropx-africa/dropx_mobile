import 'package:dropx_mobile/src/features/profile/data/dto/social_dto.dart';

abstract class SocialRepository {
  Future<SyncContactsData> syncContacts(SyncContactsDto dto);
  Future<SocialFeedData> getFeed();
}
