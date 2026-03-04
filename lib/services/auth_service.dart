import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _usersKey = 'users';
  static const _currentUserKey = 'current_user';

  Future<bool> register({required String username, required String password}) async {
    final prefs = await SharedPreferences.getInstance();
    final users = _loadUsers(prefs);
    if (users.containsKey(username)) {
      return false;
    }
    users[username] = password;
    await prefs.setString(_usersKey, jsonEncode(users));
    return true;
  }

  Future<bool> login({required String username, required String password}) async {
    final prefs = await SharedPreferences.getInstance();
    final users = _loadUsers(prefs);
    return users[username] == password;
  }

  Future<void> saveSession(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, username);
  }

  Future<String?> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString(_currentUserKey);
    if (username == null || username.isEmpty) {
      return null;
    }

    final users = _loadUsers(prefs);
    if (!users.containsKey(username)) {
      await prefs.remove(_currentUserKey);
      return null;
    }
    return username;
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  Map<String, String> _loadUsers(SharedPreferences prefs) {
    final raw = prefs.getString(_usersKey);
    if (raw == null || raw.isEmpty) {
      return {};
    }
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((key, value) => MapEntry(key, value as String));
  }
}
