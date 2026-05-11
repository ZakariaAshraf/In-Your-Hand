/// Text fields synced to/from Firestore (`users/{uid}`). Logo path is excluded.
final class BusinessProfileCloudText {
  const BusinessProfileCloudText({
    required this.businessName,
    required this.businessPhone,
    required this.businessAddress,
  });

  final String businessName;
  final String? businessPhone;
  final String? businessAddress;
}
