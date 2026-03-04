import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_info.dart';
import '../models/app_update_info.dart';
import '../services/update_service.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  Future<void> _showUpdateDialog(BuildContext context, AppUpdateInfo info) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: !info.force,
      builder: (context) {
        return AlertDialog(
          title: const Text('发现新版本', textAlign: TextAlign.center),
          content: Text(
            '最新版本：${info.version}+${info.buildNumber}\n\n更新内容：\n${info.releaseNotes}',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            if (!info.force)
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('暂不更新'),
              ),
            FilledButton(
              onPressed: () async {
                final uri = Uri.parse(info.downloadUrl);
                final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
                if (!context.mounted) return;
                if (!ok) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('下载链接打开失败', textAlign: TextAlign.center)),
                  );
                }
                Navigator.of(context).pop();
              },
              child: const Text('立即更新'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _checkUpdate(BuildContext context) async {
    try {
      final update = await const UpdateService().checkForUpdate();
      if (!context.mounted) return;
      if (update == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('当前已是最新版本', textAlign: TextAlign.center)),
        );
        return;
      }
      await _showUpdateDialog(context, update);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('检查更新失败，请稍后重试', textAlign: TextAlign.center)),
      );
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
          const Text('版本：$appVersionLabel'),
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
