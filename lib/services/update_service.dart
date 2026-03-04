import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import '../app_info.dart';
import '../models/app_update_info.dart';

class UpdateService {
  const UpdateService();

  Future<AppUpdateInfo?> fetchUpdateInfo() async {
    final uri = Uri.parse(appUpdateManifestUrl);
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      return null;
    }

    final map = jsonDecode(response.body) as Map<String, dynamic>;
    return AppUpdateInfo.fromMap(map);
  }

  Future<AppUpdateInfo?> checkForUpdate() async {
    final remote = await fetchUpdateInfo();
    if (remote == null) {
      return null;
    }

    final local = await PackageInfo.fromPlatform();
    if (_isRemoteNewer(
      remoteVersion: remote.version,
      remoteBuild: remote.buildNumber,
      localVersion: local.version,
      localBuild: int.tryParse(local.buildNumber) ?? 0,
    )) {
      return remote;
    }
    return null;
  }

  bool _isRemoteNewer({
    required String remoteVersion,
    required int remoteBuild,
    required String localVersion,
    required int localBuild,
  }) {
    final versionCompare = _compareSemanticVersion(remoteVersion, localVersion);
    if (versionCompare > 0) return true;
    if (versionCompare < 0) return false;
    return remoteBuild > localBuild;
  }

  int _compareSemanticVersion(String a, String b) {
    final aParts = a.split('.').map((item) => int.tryParse(item) ?? 0).toList();
    final bParts = b.split('.').map((item) => int.tryParse(item) ?? 0).toList();
    final length = aParts.length > bParts.length ? aParts.length : bParts.length;

    for (var i = 0; i < length; i++) {
      final left = i < aParts.length ? aParts[i] : 0;
      final right = i < bParts.length ? bParts[i] : 0;
      if (left > right) return 1;
      if (left < right) return -1;
    }
    return 0;
  }
}
