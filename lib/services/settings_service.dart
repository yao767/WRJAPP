import 'package:shared_preferences/shared_preferences.dart';

import '../models/flight_settings.dart';

class SettingsService {
  static const _settingsKey = 'global_flight_settings';

  Future<FlightSettings> loadGlobalSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_settingsKey);
    if (raw == null || raw.isEmpty) {
      return FlightSettings.defaults;
    }
    return FlightSettings.fromJson(raw);
  }

  Future<void> saveGlobalSettings(FlightSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, settings.toJson());
  }
}
