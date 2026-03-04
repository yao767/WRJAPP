import 'package:flutter/foundation.dart';

import '../models/flight_settings.dart';
import '../models/flight_task.dart';
import '../models/operation_suggestion.dart';
import '../services/auth_service.dart';
import '../services/drone_connection_service.dart';
import '../services/settings_service.dart';
import '../services/suggestion_service.dart';
import '../services/task_service.dart';

class AppState extends ChangeNotifier {
  AppState({
    AuthService? authService,
    TaskService? taskService,
      SettingsService? settingsService,
    SuggestionService? suggestionService,
    DroneConnectionService? droneConnectionService,
  })  : _authService = authService ?? AuthService(),
        _taskService = taskService ?? TaskService(),
      _settingsService = settingsService ?? SettingsService(),
        _suggestionService = suggestionService ?? SuggestionService(),
        _droneConnectionService = droneConnectionService ?? DroneConnectionService();

  final AuthService _authService;
  final TaskService _taskService;
    final SettingsService _settingsService;
  final SuggestionService _suggestionService;
  final DroneConnectionService _droneConnectionService;

  String? _currentUser;
  FlightTask? _currentTask;
  List<FlightTask> _taskHistory = [];
  FlightSettings _globalSettings = FlightSettings.defaults;
  OperationSuggestion? _latestSuggestion;

  String? get currentUser => _currentUser;
  FlightTask? get currentTask => _currentTask;
  List<FlightTask> get taskHistory => List.unmodifiable(_taskHistory);
  FlightSettings get globalSettings => _globalSettings;
  OperationSuggestion? get latestSuggestion => _latestSuggestion;
  DroneConnectionService get droneConnectionService => _droneConnectionService;

  bool get isLoggedIn => _currentUser != null;

  Future<void> init() async {
    _currentUser = await _authService.loadSession();
    _currentTask = await _taskService.loadLatestTask();
    _taskHistory = await _taskService.loadTaskHistory();
    _globalSettings = await _settingsService.loadGlobalSettings();
    notifyListeners();
  }

  Future<bool> register(String username, String password) async {
    return _authService.register(username: username, password: password);
  }

  Future<bool> login(String username, String password) async {
    final success = await _authService.login(username: username, password: password);
    if (success) {
      _currentUser = username;
      await _authService.saveSession(username);
      notifyListeners();
    }
    return success;
  }

  Future<void> logout() async {
    _currentUser = null;
    await _authService.clearSession();
    notifyListeners();
  }

  Future<void> saveTask(FlightTask task) async {
    _currentTask = task;
    await _taskService.saveTask(task);
    _taskHistory = await _taskService.loadTaskHistory();
    notifyListeners();
  }

  Future<void> setCurrentTaskFromHistory(FlightTask task) async {
    _currentTask = task;
    await _taskService.saveTask(task);
    _taskHistory = await _taskService.loadTaskHistory();
    notifyListeners();
  }

  Future<void> updateGlobalSettings(FlightSettings settings) async {
    _globalSettings = settings;
    await _settingsService.saveGlobalSettings(settings);
    notifyListeners();
  }

  OperationSuggestion buildSuggestion({
    required String crop,
    required String season,
    required String taskType,
    required double humidity,
    required double rainfall,
    required double sunshine,
  }) {
    _latestSuggestion = _suggestionService.generateSuggestion(
      crop: crop,
      season: season,
      taskType: taskType,
      humidity: humidity,
      rainfall: rainfall,
      sunshine: sunshine,
    );
    notifyListeners();
    return _latestSuggestion!;
  }
}
