import 'business_profile_cloud_text.dart';

abstract class BusinessProfileRemoteDataSource {
  /// Merge-only write; must not overwrite unrelated `users/{uid}` fields.
  Future<void> upsertBusinessText({
    required String uid,
    required String businessName,
    String? businessPhone,
    String? businessAddress,
  });

  /// `null` if no document exists.
  Future<BusinessProfileCloudText?> fetchBusinessText(String uid);
}
