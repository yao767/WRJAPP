import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../utils/app_feedback.dart';

class DeviceSettingsPage extends StatefulWidget {
  const DeviceSettingsPage({super.key});

  @override
  State<DeviceSettingsPage> createState() => _DeviceSettingsPageState();
}

class _DeviceSettingsPageState extends State<DeviceSettingsPage> {
  String? _selectedDevice;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final service = appState.droneConnectionService;

    return Scaffold(
      appBar: AppBar(title: const Text('设备连接')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('蓝牙配对（接口预留）', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          FutureBuilder<List<String>>(
            future: service.scanDevices(),
            builder: (context, snapshot) {
              final devices = snapshot.data ?? [];
              return DropdownButtonFormField<String>(
                value: _selectedDevice,
                decoration: const InputDecoration(labelText: '选择遥控器设备'),
                items: devices
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedDevice = v),
              );
            },
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: [
              FilledButton(
                onPressed: _selectedDevice == null
                    ? null
                    : () async {
                        await service.connect(_selectedDevice!);
                        if (!mounted) return;
                        setState(() {});
                        showAppToast(context, '已连接：${service.deviceName}');
                      },
                child: const Text('连接设备'),
              ),
              OutlinedButton(
                onPressed: service.isConnected
                    ? () async {
                        await service.disconnect();
                        if (!mounted) return;
                        setState(() {});
                      }
                    : null,
                child: const Text('断开连接'),
              ),
              FilledButton.tonal(
                onPressed: service.isConnected
                    ? () async {
                        try {
                          await service.pushFlightParams({
                            'mode': appState.globalSettings.workMode,
                            'height': appState.globalSettings.height,
                            'speed': appState.globalSettings.speed,
                            'angle': appState.globalSettings.angle,
                          });
                        } on StateError catch (error) {
                          if (!mounted) return;
                          showAppToast(context, error.message);
                          return;
                        }
                        if (!mounted) return;
                        showAppToast(context, '参数已下发（模拟）');
                      }
                    : null,
                child: const Text('下发参数'),
              )
            ],
          ),
          const SizedBox(height: 10),
          Text(service.isConnected ? '当前连接：${service.deviceName}' : '当前状态：未连接'),
        ],
      ),
    );
  }
}
