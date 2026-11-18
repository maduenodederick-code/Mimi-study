import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  static const _tasksKey = 'mimi.study.tasks.v1';
  static const _notesKey = 'mimi.study.notes.v1';
  static const _focusMinutesKey = 'mimi.study.focus_minutes.v1';
  static const _focusSessionsKey = 'mimi.study.focus_sessions.v1';

  static Future<List<Map<String, dynamic>>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_tasksKey);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveTasks(List<Map<String, dynamic>> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tasksKey, jsonEncode(tasks));
  }

  static Future<List<Map<String, dynamic>>> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_notesKey);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveNotes(List<Map<String, dynamic>> notes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_notesKey, jsonEncode(notes));
  }

  static Future<int> loadFocusMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_focusMinutesKey) ?? 0;
  }

  static Future<void> saveFocusMinutes(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_focusMinutesKey, minutes);
  }

  static Future<List<Map<String, dynamic>>> loadFocusSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_focusSessionsKey);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveFocusSessions(List<Map<String, dynamic>> sessions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_focusSessionsKey, jsonEncode(sessions));
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tasksKey);
    await prefs.remove(_notesKey);
    await prefs.remove(_focusMinutesKey);
    await prefs.remove(_focusSessionsKey);
  }
}
