import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

Future<String?> copyGalleryImageToAppDocuments({
  required String workspaceId,
  required String sourcePath,
}) async {
  final source = File(sourcePath);
  if (!await source.exists()) return null;

  final dir = await getApplicationDocumentsDirectory();
  final workspaceDir =
      Directory(p.join(dir.path, 'business_logos', workspaceId));
  await workspaceDir.create(recursive: true);

  final ext = p.extension(sourcePath);
  final safeExt = ext.isNotEmpty ? ext : '.jpg';
  final destPath = p.join(workspaceDir.path, '${const Uuid().v4()}$safeExt');
  await source.copy(destPath);
  return destPath;
}

Future<void> deleteBusinessLogoFile(String? logoLocalPath) async {
  if (logoLocalPath == null || logoLocalPath.isEmpty) return;
  try {
    final f = File(logoLocalPath);
    if (await f.exists()) await f.delete();
  } catch (_) {}
}

Future<void> deleteAllLogosForWorkspace(String workspaceId) async {
  if (workspaceId.isEmpty) return;
  try {
    final dir = await getApplicationDocumentsDirectory();
    final workspaceDir =
        Directory(p.join(dir.path, 'business_logos', workspaceId));
    if (await workspaceDir.exists()) {
      await workspaceDir.delete(recursive: true);
    }
  } catch (_) {}
}
