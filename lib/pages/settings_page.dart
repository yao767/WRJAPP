import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import 'about_page.dart';
import 'device_settings_page.dart';
import 'flight_settings_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final service = appState.droneConnectionService;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _summaryCard(appState),
        const SizedBox(height: 12),
        _sectionTitle('飞行参数'),
        _settingsTile(
          title: '飞行姿态（全局参数）',
          subtitle: '工作模式：${appState.globalSettings.workMode}',
          icon: Icons.tune,
          onTap: () => _openPage(context, const FlightSettingsPage()),
        ),
        const SizedBox(height: 12),
        _sectionTitle('设备连接'),
        _settingsTile(
          title: '蓝牙配对',
          subtitle: service.isConnected ? '已连接：${service.deviceName}' : '未连接',
          icon: Icons.bluetooth,
          onTap: () => _openPage(context, const DeviceSettingsPage()),
        ),
        const SizedBox(height: 12),
        _sectionTitle('关于'),
        FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (context, snapshot) {
            final info = snapshot.data;
            final versionLabel = info == null ? '获取中...' : '${info.version}+${info.buildNumber}';
            return _settingsTile(
              title: '关于与更新',
              subtitle: '版本：$versionLabel',
              icon: Icons.info_outline,
              onTap: () => _openPage(context, const AboutPage()),
            );
          },
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
  }

  Widget _summaryCard(AppState appState) {
    final settings = appState.globalSettings;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('概览', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('工作模式：${settings.workMode}'),
            Text('高度：${settings.height.toStringAsFixed(1)}m  速度：${settings.speed.toStringAsFixed(1)}m/s  角度：${settings.angle.toStringAsFixed(0)}°'),
          ],
        ),
      ),
    );
  }

  Widget _settingsTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Future<void> _openPage(BuildContext context, Widget page) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => page),
    );
  }
}
