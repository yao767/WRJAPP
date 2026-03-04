import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/flight_task.dart';
import '../state/app_state.dart';
import 'task_editor_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final task = appState.currentTask;
    final history = appState.taskHistory;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _CurrentTaskCard(task: task),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('任务历史列表', style: Theme.of(context).textTheme.titleMedium),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: history.isEmpty
                ? const Center(child: Text('暂无历史任务，先创建并保存一个任务'))
                : ListView.separated(
                    itemCount: history.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = history[index];
                      final isCurrent = task != null && _isSameTask(task, item);
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(child: Text('${index + 1}')),
                          title: Text('${item.taskType} | ${item.crop} | ${item.season}'),
                          subtitle: Text(
                            '高${item.height.toStringAsFixed(1)}m  速${item.speed.toStringAsFixed(1)}m/s  角${item.angle.toStringAsFixed(0)}°\n${item.updatedAt.toLocal()}',
                          ),
                          isThreeLine: true,
                          trailing: isCurrent
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : FilledButton.tonal(
                                  onPressed: () async {
                                    await context.read<AppState>().setCurrentTaskFromHistory(item);
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('已设为当前任务')),
                                    );
                                  },
                                  child: const Text('设为当前'),
                                ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TaskEditorPage()),
              ),
              icon: const Icon(Icons.add_circle_outline),
              label: Text(task == null ? '添加飞行任务' : '编辑飞行任务'),
            ),
          )
        ],
      ),
    );
  }

  bool _isSameTask(FlightTask first, FlightTask second) {
    return first.updatedAt == second.updatedAt;
  }
}

class _CurrentTaskCard extends StatelessWidget {
  const _CurrentTaskCard({required this.task});

  final FlightTask? task;

  @override
  Widget build(BuildContext context) {
    if (task == null) {
      return SizedBox(
        height: 190,
        child: Center(
          child: GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TaskEditorPage()),
            ),
            child: CircleAvatar(
              radius: 56,
              child: Icon(Icons.add, size: 52, color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('当前任务：${task!.taskType}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('作物：${task!.crop} | 时节：${task!.season}'),
            Text('起飞：${task!.takeoffMode} / 运作：${task!.operationMode} / 降落：${task!.landingMode}'),
            Text('高度：${task!.height.toStringAsFixed(1)}m  速度：${task!.speed.toStringAsFixed(1)}m/s  角度：${task!.angle.toStringAsFixed(0)}°'),
            const SizedBox(height: 8),
            Text('更新时间：${task!.updatedAt.toLocal()}'),
          ],
        ),
      ),
    );
  }
}
