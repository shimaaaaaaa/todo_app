import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../models/user_stats.dart';

class TodoRepository {
  static const _taskListKey = 'taskList';
  static const _userStatsKey = 'userStats';

  Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksJson = prefs.getString(_taskListKey);
    if (tasksJson == null) {
      return [];
    }
    final List<dynamic> decoded = jsonDecode(tasksJson);
    return decoded.map((json) => Task.fromJson(json)).toList();
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString(_taskListKey, encoded);
  }

  Future<UserStats> loadUserStats() async {
    final prefs = await SharedPreferences.getInstance();
    final String? statsJson = prefs.getString(_userStatsKey);
    if (statsJson == null) {
      return UserStats();
    }
    return UserStats.fromJson(jsonDecode(statsJson));
  }

  Future<void> saveUserStats(UserStats stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userStatsKey, jsonEncode(stats.toJson()));
  }
}
