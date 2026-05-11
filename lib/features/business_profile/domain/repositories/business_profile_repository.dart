import '../entities/business_profile.dart';

abstract class BusinessProfileRepository {
  Future<BusinessProfile?> getProfile(String workspaceId);

  Future<void> saveProfile(BusinessProfile profile);

  Future<void> clearProfile(String workspaceId);
}

