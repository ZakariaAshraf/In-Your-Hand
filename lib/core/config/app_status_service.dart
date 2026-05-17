import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Remote `app_config/status` document from Firestore.
class AppStatusConfig {
  const AppStatusConfig({
    required this.minVersionCode,
    required this.isUnderMaintenance,
    required this.storeUrl,
  });

  final int minVersionCode;
  final bool isUnderMaintenance;
  final String storeUrl;

  /// Fail-open defaults when Firestore is unreachable or the doc is missing.
  static const AppStatusConfig defaults = AppStatusConfig(
    minVersionCode: 0,
    isUnderMaintenance: false,
    storeUrl: '',
  );

  factory AppStatusConfig.fromFirestore(Map<String, dynamic> data) {
    return AppStatusConfig(
      minVersionCode: _asInt(data['minVersionCode']),
      isUnderMaintenance: data['isUnderMaintenance'] == true,
      storeUrl: (data['storeUrl'] as String?)?.trim() ?? '',
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

/// Result of the startup gate (maintenance / force update / proceed).
sealed class AppStartupGate {
  const AppStartupGate();

  const factory AppStartupGate.ok() = AppStartupOk;

  const factory AppStartupGate.maintenance() = AppStartupMaintenance;

  const factory AppStartupGate.forceUpdate({required String storeUrl}) =
      AppStartupForceUpdate;
}

final class AppStartupOk extends AppStartupGate {
  const AppStartupOk();
}

final class AppStartupMaintenance extends AppStartupGate {
  const AppStartupMaintenance();
}

final class AppStartupForceUpdate extends AppStartupGate {
  const AppStartupForceUpdate({required this.storeUrl});

  final String storeUrl;
}

/// Fetches `app_config/status` and compares [PackageInfo.buildNumber] to [AppStatusConfig.minVersionCode].
class AppStatusService {
  AppStatusService._();

  static final AppStatusService instance = AppStatusService._();

  static const String _collection = 'app_config';
  static const String _documentId = 'status';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Reads remote config; returns [AppStatusConfig.defaults] on error (fail-open).
  Future<AppStatusConfig> fetchConfig() async {
    try {
      final snap = await _firestore
          .collection(_collection)
          .doc(_documentId)
          .get(const GetOptions(source: Source.serverAndCache));
      if (!snap.exists || snap.data() == null) {
        return AppStatusConfig.defaults;
      }
      return AppStatusConfig.fromFirestore(snap.data()!);
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('AppStatusService.fetchConfig failed: $e\n$st');
      }
      return AppStatusConfig.defaults;
    }
  }

  /// Current app build number (Android `versionCode` / iOS `CFBundleVersion`).
  Future<int> currentVersionCode() async {
    final info = await PackageInfo.fromPlatform();
    return int.tryParse(info.buildNumber) ?? 0;
  }

  /// Resolves maintenance vs force-update vs normal startup.
  Future<AppStartupGate> evaluate() async {
    final config = await fetchConfig();
    final versionCode = await currentVersionCode();

    if (config.isUnderMaintenance) {
      return const AppStartupGate.maintenance();
    }

    if (versionCode < config.minVersionCode) {
      var storeUrl = config.storeUrl;
      if (storeUrl.isEmpty) {
        final info = await PackageInfo.fromPlatform();
        storeUrl =
            'https://play.google.com/store/apps/details?id=${info.packageName}';
      }
      return AppStartupGate.forceUpdate(storeUrl: storeUrl);
    }

    return const AppStartupGate.ok();
  }
}
