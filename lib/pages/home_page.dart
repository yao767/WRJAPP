import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/flight_task.dart';
import '../state/app_state.dart';
import '../utils/app_feedback.dart';
import '../utils/time_format.dart';
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
                      final taskName = item.taskName?.trim().isNotEmpty == true ? item.taskName! : '${item.taskType}任务';
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(child: Text('${index + 1}')),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$taskName | ${item.crop} | ${item.season}',
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '高${item.height.toStringAsFixed(1)}m  速${item.speed.toStringAsFixed(1)}m/s  角${item.angle.toStringAsFixed(0)}°',
                                    ),
                                    Text(formatToMinute(item.updatedAt)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 106,
                                child: Column(
                                  children: [
                                    FilledButton.tonal(
                                      onPressed: isCurrent
                                          ? null
                                          : () async {
                                              await context.read<AppState>().setCurrentTaskFromHistory(item);
                                              if (!context.mounted) return;
                                              showAppToast(context, '已设为当前任务');
                                            },
                                      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(38)),
                                      child: Text(
                                        isCurrent ? '当前任务' : '设为当前',
                                        maxLines: 1,
                                        softWrap: false,
                                        overflow: TextOverflow.fade,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).push(
                                        MaterialPageRoute(builder: (_) => TaskEditorPage(editingTask: item)),
                                      ),
                                      child: const Text('编辑任务'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
    return first.id == second.id;
  }
}

class _CurrentTaskCard extends StatelessWidget {
  const _CurrentTaskCard({required this.task});

  final FlightTask? task;

  @override
  Widget build(BuildContext context) {
    final taskName = task?.taskName?.trim().isNotEmpty == true ? task!.taskName! : '${task?.taskType ?? '默认'}任务';

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
            Text(
              '当前任务：$taskName',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text('作物：${task!.crop} | 时节：${task!.season}'),
            Text('起飞：${task!.takeoffMode} / 运作：${task!.operationMode} / 降落：${task!.landingMode}'),
            Text('高度：${task!.height.toStringAsFixed(1)}m  速度：${task!.speed.toStringAsFixed(1)}m/s  角度：${task!.angle.toStringAsFixed(0)}°'),
            const SizedBox(height: 8),
            Text('更新时间：${formatToMinute(task!.updatedAt)}'),
          ],
        ),
      ),
    );
  }
}
