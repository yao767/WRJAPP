import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/flight_task.dart';
import '../state/app_state.dart';
import '../utils/app_feedback.dart';

class TaskEditorPage extends StatefulWidget {
  const TaskEditorPage({super.key, this.editingTask});

  final FlightTask? editingTask;

  @override
  State<TaskEditorPage> createState() => _TaskEditorPageState();
}

class _TaskEditorPageState extends State<TaskEditorPage> {
  final _taskNameController = TextEditingController();

  String _taskType = '喷洒';
  String _crop = '水稻';
  String _season = '春季';
  String _takeoffMode = '自动起飞';
  String _operationMode = '标准喷洒';
  String _landingMode = '定点降落';
  double _height = 2.5;
  double _speed = 4.0;
  double _angle = 35;
  bool _initialized = false;

  double _humidity = 60;
  double _rainfall = 10;
  double _sunshine = 6;

  @override
  void dispose() {
    _taskNameController.dispose();
    super.dispose();
  }

  void _applySuggestion() {
    final suggestion = context.read<AppState>().buildSuggestion(
          crop: _crop,
          season: _season,
          taskType: _taskType,
          humidity: _humidity,
          rainfall: _rainfall,
          sunshine: _sunshine,
        );
    setState(() {
      _height = suggestion.recommendedHeight;
      _speed = suggestion.recommendedSpeed;
      _angle = suggestion.recommendedAngle;
      _operationMode = suggestion.operationMode;
    });
    showAppToast(context, '已应用建议：${suggestion.summary}');
  }

  Future<void> _save() async {
    final sourceTask = widget.editingTask;
    final taskName = _taskNameController.text.trim();
    final task = FlightTask(
      id: sourceTask?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      taskName: taskName.isEmpty ? null : taskName,
      taskType: _taskType,
      crop: _crop,
      season: _season,
      takeoffMode: _takeoffMode,
      operationMode: _operationMode,
      landingMode: _landingMode,
      height: _height,
      speed: _speed,
      angle: _angle,
      updatedAt: DateTime.now(),
    );

    await context.read<AppState>().saveTask(task);
    if (!mounted) return;
    showAppToast(context, '任务参数已保存');
    Navigator.of(context).pop();
  }

  Future<void> _deleteCurrentTask() async {
    final sourceTask = widget.editingTask;
    if (sourceTask == null) return;

    await context.read<AppState>().deleteTaskById(sourceTask.id);
    if (!mounted) return;
    showAppToast(context, '任务已删除');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      final sourceTask = widget.editingTask;
      if (sourceTask != null) {
        _taskNameController.text = sourceTask.taskName ?? '';
        _taskType = sourceTask.taskType;
        _crop = sourceTask.crop;
        _season = sourceTask.season;
        _takeoffMode = sourceTask.takeoffMode;
        _operationMode = sourceTask.operationMode;
        _landingMode = sourceTask.landingMode;
        _height = sourceTask.height;
        _speed = sourceTask.speed;
        _angle = sourceTask.angle;
      } else {
        final globalSettings = context.read<AppState>().globalSettings;
        _height = globalSettings.height;
        _speed = globalSettings.speed;
        _angle = globalSettings.angle;
      }
      _initialized = true;
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.editingTask == null ? '添加飞行任务' : '编辑飞行任务')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _taskNameController,
            decoration: const InputDecoration(
              labelText: '任务名称（可选）',
              hintText: '不填写则自动使用默认任务名称',
            ),
          ),
          const SizedBox(height: 10),
          _dropdown('飞行分类', _taskType, const ['喷洒', '除草', '杀菌'], (v) => _taskType = v),
          _dropdown('作物类型', _crop, const ['水稻', '小麦', '玉米', '果树'], (v) => _crop = v),
          _dropdown('当前时节', _season, const ['春季', '夏季', '秋季', '冬季'], (v) => _season = v),
          _dropdown('起飞状态', _takeoffMode, const ['自动起飞', '手动起飞'], (v) => _takeoffMode = v),
          _dropdown('运作状态', _operationMode, const ['标准喷洒', '低漂移精细喷洒'], (v) => _operationMode = v),
          _dropdown('降落状态', _landingMode, const ['定点降落', '返航降落'], (v) => _landingMode = v),
          const SizedBox(height: 8),
          _slider('飞行高度(m)', _height, 1.5, 6.0, (v) => setState(() => _height = v)),
          _slider('飞行速度(m/s)', _speed, 2.0, 7.0, (v) => setState(() => _speed = v)),
          _slider('喷头角度(°)', _angle, 20, 60, (v) => setState(() => _angle = v)),
          const Divider(height: 24),
          const Text('环境因子（用于建议）', style: TextStyle(fontWeight: FontWeight.bold)),
          _slider('湿度(%)', _humidity, 20, 100, (v) => setState(() => _humidity = v)),
          _slider('雨量(mm)', _rainfall, 0, 80, (v) => setState(() => _rainfall = v)),
          _slider('光照(h)', _sunshine, 0, 12, (v) => setState(() => _sunshine = v)),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: _applySuggestion,
            icon: const Icon(Icons.auto_fix_high),
            label: const Text('一键建议并设置参数'),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save),
            label: const Text('保存当前参数'),
          ),
          if (widget.editingTask != null) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _deleteCurrentTask,
              icon: const Icon(Icons.delete_outline),
              label: const Text('删除此任务'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _dropdown(String label, String value, List<String> items, ValueChanged<String> onChange) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: label),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (v) {
          if (v == null) return;
          setState(() => onChange(v));
        },
      ),
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
