class BusinessProfile {
  final String workspaceId;
  final String businessName;
  final String? phone;
  final String? address;

  /// Absolute path under app documents (device-only). Never synced to Firebase.
  final String? logoLocalPath;

  const BusinessProfile({
    required this.workspaceId,
    required this.businessName,
    this.phone,
    this.address,
    this.logoLocalPath,
  });

  BusinessProfile copyWith({
    String? businessName,
    String? phone,
    String? address,
    String? logoLocalPath,
  }) {
    return BusinessProfile(
      workspaceId: workspaceId,
      businessName: businessName ?? this.businessName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      logoLocalPath: logoLocalPath ?? this.logoLocalPath,
    );
  }
}
