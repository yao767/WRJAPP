import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../app_info.dart';
import '../models/app_update_info.dart';
import '../services/update_service.dart';
import '../utils/app_feedback.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  Future<void> _showUpdateDialog(BuildContext context, AppUpdateInfo info) async {
    final updateService = const UpdateService();
    await showDialog<void>(
      context: context,
      barrierDismissible: !info.force,
      builder: (context) {
        var isDownloading = false;
        var progress = 0.0;
        String? statusText;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('发现新版本', textAlign: TextAlign.center),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '最新版本：${info.version}+${info.buildNumber}\n\n更新内容：\n${info.releaseNotes}',
                    textAlign: TextAlign.center,
                  ),
                  if (isDownloading) ...[
                    const SizedBox(height: 12),
                    LinearProgressIndicator(value: progress),
                    const SizedBox(height: 8),
                    Text('下载进度 ${(progress * 100).toStringAsFixed(0)}%', textAlign: TextAlign.center),
                  ],
                  if (statusText != null) ...[
                    const SizedBox(height: 8),
                    Text(statusText!, textAlign: TextAlign.center),
                  ],
                ],
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                if (!info.force)
                  TextButton(
                    onPressed: isDownloading ? null : () => Navigator.of(context).pop(),
                    child: const Text('暂不更新'),
                  ),
                FilledButton(
                  onPressed: isDownloading
                      ? null
                      : () async {
                          setDialogState(() {
                            isDownloading = true;
                            progress = 0;
                            statusText = null;
                          });
                          try {
                            await updateService.downloadAndInstallApk(
                              info: info,
                              onProgress: (value) {
                                setDialogState(() => progress = value);
                              },
                            );
                            if (!context.mounted) return;
                            setDialogState(() {
                              isDownloading = false;
                              statusText = '下载完成，已调起安装界面';
                            });
                          } catch (error) {
                            if (!context.mounted) return;
                            setDialogState(() {
                              isDownloading = false;
                              statusText = '更新失败：$error';
                            });
                          }
                        },
                  child: Text(isDownloading ? '下载中...' : '立即更新'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _checkUpdate(BuildContext context) async {
    try {
      final update = await const UpdateService().checkForUpdate();
      if (!context.mounted) return;
      if (update == null) {
        showAppToast(context, '当前已是最新版本');
        return;
      }
      await _showUpdateDialog(context, update);
    } catch (error) {
      if (!context.mounted) return;
      showAppToast(context, '检查更新失败：$error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          const Text(appProjectName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final info = snapshot.data;
              final label = info == null ? appVersionLabel : '${info.version}+${info.buildNumber}';
              return Text('版本：$label');
            },
          ),
          const Text('联系方式：$appContactEmail'),
          const SizedBox(height: 10),
          const Text('使用说明：'),
          ...appUsageSteps.map((item) => Text(item)),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: () => _checkUpdate(context),
            icon: const Icon(Icons.system_update_alt),
            label: const Text('手动检查更新'),
          ),
          const SizedBox(height: 10),
          const Text(appUsageSyncNote),
          const SizedBox(height: 12),
          const Text(appFlightControlNote),
        ],
      ),
    );
  }
}
