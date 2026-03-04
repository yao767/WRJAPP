import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/flight_task.dart';

class TaskService {
  static const _taskKey = 'latest_task';
  static const _taskHistoryKey = 'task_history';
  static const _maxHistoryCount = 50;

  Future<void> saveTask(FlightTask task) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_taskKey, task.toJson());

    final history = await loadTaskHistory();
    final updatedHistory = [task, ...history].take(_maxHistoryCount).toList();
    final historyRaw = jsonEncode(updatedHistory.map((item) => item.toMap()).toList());
    await prefs.setString(_taskHistoryKey, historyRaw);
  }

  Future<FlightTask?> loadLatestTask() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_taskKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return FlightTask.fromJson(raw);
  }

  Future<List<FlightTask>> loadTaskHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_taskHistoryKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => FlightTask.fromMap(item as Map<String, dynamic>))
        .toList();
  }
}
