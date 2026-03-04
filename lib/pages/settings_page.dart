import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _workMode = '标准模式';
  double _globalHeight = 2.5;
  double _globalSpeed = 4.0;
  double _globalAngle = 35;
  String? _selectedDevice;
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final service = appState.droneConnectionService;

    if (!_initialized) {
      final globalSettings = appState.globalSettings;
      _workMode = globalSettings.workMode;
      _globalHeight = globalSettings.height;
      _globalSpeed = globalSettings.speed;
      _globalAngle = globalSettings.angle;
      _initialized = true;
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('飞行姿态（全局参数）', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _workMode,
          decoration: const InputDecoration(labelText: '工作模式'),
          items: const ['标准模式', '节能模式', '高精度模式']
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) {
            if (v == null) return;
            setState(() => _workMode = v);
          },
        ),
        const SizedBox(height: 8),
        _slider('全局高度(m)', _globalHeight, 1.5, 6.0, (v) => setState(() => _globalHeight = v)),
        _slider('全局速度(m/s)', _globalSpeed, 2.0, 7.0, (v) => setState(() => _globalSpeed = v)),
        _slider('全局角度(°)', _globalAngle, 20, 60, (v) => setState(() => _globalAngle = v)),
        const Divider(height: 24),
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
            FilledButton.tonal(
              onPressed: () async {
                await appState.updateGlobalSettings(
                  appState.globalSettings.copyWith(
                    workMode: _workMode,
                    height: _globalHeight,
                    speed: _globalSpeed,
                    angle: _globalAngle,
                  ),
                );
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('全局参数已保存', textAlign: TextAlign.center)),
                );
              },
              child: const Text('保存全局参数'),
            ),
            FilledButton(
              onPressed: _selectedDevice == null
                  ? null
                  : () async {
                      await service.connect(_selectedDevice!);
                      if (!mounted) return;
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('已连接：${service.deviceName}', textAlign: TextAlign.center)),
                      );
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
                          'mode': _workMode,
                          'height': _globalHeight,
                          'speed': _globalSpeed,
                          'angle': _globalAngle,
                        });
                      } on StateError catch (error) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error.message, textAlign: TextAlign.center)),
                        );
                        return;
                      }
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('参数已下发（模拟）', textAlign: TextAlign.center)),
                      );
                    }
                  : null,
              child: const Text('下发参数'),
            )
          ],
        ),
        const SizedBox(height: 10),
        Text(service.isConnected ? '当前连接：${service.deviceName}' : '当前状态：未连接'),
      ],
    );
  }

  Widget _slider(String label, double value, double min, double max, ValueChanged<double> onChange) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label：${value.toStringAsFixed(1)}'),
        Slider(value: value, min: min, max: max, onChanged: onChange),
      ],
    );
  }
}
