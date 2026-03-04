class AppUpdateInfo {
  const AppUpdateInfo({
    required this.version,
    required this.buildNumber,
    required this.downloadUrl,
    required this.releaseNotes,
    required this.force,
  });

  final String version;
  final int buildNumber;
  final String downloadUrl;
  final String releaseNotes;
  final bool force;

  factory AppUpdateInfo.fromMap(Map<String, dynamic> map) {
    return AppUpdateInfo(
      version: map['version'] as String,
      buildNumber: map['buildNumber'] as int,
      downloadUrl: map['downloadUrl'] as String,
      releaseNotes: (map['releaseNotes'] as String?) ?? '',
      force: (map['force'] as bool?) ?? false,
    );
  }
}
