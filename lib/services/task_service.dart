import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/flight_task.dart';

class TaskService {
  static const _taskKey = 'latest_task';
  static const _taskHistoryKey = 'task_history';
  static const _maxHistoryCount = 50;

  Future<void> saveTask(FlightTask task) async {
    await setLatestTask(task);

    final history = await loadTaskHistory();
    history.removeWhere((item) => item.id == task.id);
    final updatedHistory = [task, ...history].take(_maxHistoryCount).toList();
    await _saveTaskHistory(updatedHistory);
  }

  Future<void> setLatestTask(FlightTask task) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_taskKey, task.toJson());
  }

  Future<void> deleteTaskById(String id) async {
    final history = await loadTaskHistory();
    final updatedHistory = history.where((item) => item.id != id).toList();
    await _saveTaskHistory(updatedHistory);

    final prefs = await SharedPreferences.getInstance();
    final latest = await loadLatestTask();
    if (latest?.id == id) {
      if (updatedHistory.isEmpty) {
        await prefs.remove(_taskKey);
      } else {
        await prefs.setString(_taskKey, updatedHistory.first.toJson());
      }
    }
  }

  Future<void> _saveTaskHistory(List<FlightTask> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final historyRaw = jsonEncode(tasks.map((item) => item.toMap()).toList());
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
