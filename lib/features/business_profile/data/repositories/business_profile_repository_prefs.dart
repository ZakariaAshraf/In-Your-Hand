import 'dart:convert';

import '../../../../core/cache/cache_helper.dart';
import '../../domain/entities/business_profile.dart';
import '../../domain/repositories/business_profile_repository.dart';

class BusinessProfileRepositoryPrefs implements BusinessProfileRepository {
  BusinessProfileRepositoryPrefs();

  static String _key(String workspaceId) => 'business_profile_$workspaceId';

  @override
  Future<BusinessProfile?> getProfile(String workspaceId) async {
    final raw = CacheHelper.getString(key: _key(workspaceId));
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final logoLocalPath = _readLogoLocalPath(map);
      return BusinessProfile(
        workspaceId: workspaceId,
        businessName: (map['businessName'] as String?)?.trim() ?? '',
        phone: (map['phone'] as String?)?.trim(),
        address: (map['address'] as String?)?.trim(),
        logoLocalPath: logoLocalPath,
      );
    } catch (_) {
      return null;
    }
  }

  /// Prefer [logoLocalPath]; fall back to legacy [logoPath] for older installs.
  static String? _readLogoLocalPath(Map<String, dynamic> map) {
    final primary = (map['logoLocalPath'] as String?)?.trim();
    if (primary != null && primary.isNotEmpty) return primary;
    final legacy = (map['logoPath'] as String?)?.trim();
    if (legacy != null && legacy.isNotEmpty) return legacy;
    return null;
  }

  @override
  Future<void> saveProfile(BusinessProfile profile) async {
    final map = <String, dynamic>{
      'businessName': profile.businessName,
      'phone': profile.phone,
      'address': profile.address,
      'logoLocalPath': profile.logoLocalPath,
    };
    await CacheHelper.set(key: _key(profile.workspaceId), value: jsonEncode(map));
  }

  @override
  Future<void> clearProfile(String workspaceId) async {
    await CacheHelper.remove(key: _key(workspaceId));
  }
}
