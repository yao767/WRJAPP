import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_update_info.dart';
import '../services/update_service.dart';
import '../state/app_state.dart';
import '../utils/app_feedback.dart';
import 'about_page.dart';
import 'home_page.dart';
import 'settings_page.dart';
import 'suggestion_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  bool _checkedUpdate = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_checkedUpdate) return;
    _checkedUpdate = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkUpdate());
  }

  Future<void> _checkUpdate() async {
    AppUpdateInfo? update;
    try {
      update = await const UpdateService().checkForUpdate();
    } catch (_) {
      if (mounted) showAppToast(context, '检查更新失败，请稍后重试');
      return;
    }
    if (!mounted || update == null) return;
    await _showUpdateDialog(update);
  }

  Future<void> _showUpdateDialog(AppUpdateInfo info) async {
    if (!mounted) return;
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

  @override
  Widget build(BuildContext context) {
    final pages = const [
      HomePage(),
      SuggestionPage(),
      SettingsPage(),
      AboutPage(),
    ];
    final titles = const ['主页面', '建议页面', '设置页面', '关于页面'];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_index]),
        actions: [
          IconButton(
            onPressed: () async {
              await context.read<AppState>().logout();
            },
            icon: const Icon(Icons.logout),
            tooltip: '退出登录',
          )
        ],
      ),
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: '主页面'),
          NavigationDestination(icon: Icon(Icons.tips_and_updates), label: '建议'),
          NavigationDestination(icon: Icon(Icons.settings), label: '设置'),
          NavigationDestination(icon: Icon(Icons.info), label: '关于'),
        ],
      ),
    );
  }
}
