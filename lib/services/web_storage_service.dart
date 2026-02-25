import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/plant.dart';
import '../models/log_entry.dart';
import '../models/note.dart';

/// Web環境向け永続化ストレージ。
/// SharedPreferences（= localStorage）に JSON シリアライズしてデータを保存する。
class WebStorageService {
  static final WebStorageService _instance = WebStorageService._internal();
  factory WebStorageService() => _instance;
  WebStorageService._internal();

  static const _keyPlants = 'web_plants';
  static const _keyLogs = 'web_logs';
  static const _keyNotes = 'web_notes';

  // ─────────────────────────────────────────
  // Plant 操作
  // ─────────────────────────────────────────

  Future<List<Plant>> getAllPlants() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyPlants);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => Plant.fromMap(Map<String, dynamic>.from(e)))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<Plant?> getPlant(String id) async {
    final plants = await getAllPlants();
    try {
      return plants.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> insertPlant(Plant plant) async {
    final prefs = await SharedPreferences.getInstance();
    final plants = await getAllPlants();
    plants.removeWhere((p) => p.id == plant.id);
    plants.add(plant);
    await prefs.setString(
        _keyPlants, jsonEncode(plants.map((p) => p.toMap()).toList()));
  }

  Future<void> updatePlant(Plant plant) async {
    await insertPlant(plant);
  }

  Future<void> deletePlant(String id) async {
    final prefs = await SharedPreferences.getInstance();
    // 植物を削除
    final plants = await getAllPlants();
    plants.removeWhere((p) => p.id == id);
    await prefs.setString(
        _keyPlants, jsonEncode(plants.map((p) => p.toMap()).toList()));
    // 関連ログを削除
    final logs = await _getAllLogs();
    logs.removeWhere((l) => l.plantId == id);
    await prefs.setString(
        _keyLogs, jsonEncode(logs.map((l) => l.toMap()).toList()));
  }

  // ─────────────────────────────────────────
  // LogEntry 操作
  // ─────────────────────────────────────────

  Future<List<LogEntry>> _getAllLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyLogs);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => LogEntry.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<LogEntry>> getLogsByPlant(String plantId) async {
    final logs = await _getAllLogs();
    return logs.where((l) => l.plantId == plantId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<List<LogEntry>> getLogsByPlantAndType(
      String plantId, LogType type) async {
    final logs = await _getAllLogs();
    return logs
        .where((l) => l.plantId == plantId && l.type == type)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<List<LogEntry>> getLogsByDate(DateTime date) async {
    final logs = await _getAllLogs();
    return logs.where((l) {
      return l.date.year == date.year &&
          l.date.month == date.month &&
          l.date.day == date.day;
    }).toList();
  }

  Future<void> insertLog(LogEntry log) async {
    final prefs = await SharedPreferences.getInstance();
    final logs = await _getAllLogs();
    logs.removeWhere((l) => l.id == log.id);
    logs.add(log);
    await prefs.setString(
        _keyLogs, jsonEncode(logs.map((l) => l.toMap()).toList()));
  }

  Future<void> updateLog(LogEntry log) async {
    await insertLog(log);
  }

  Future<void> deleteLog(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final logs = await _getAllLogs();
    logs.removeWhere((l) => l.id == id);
    await prefs.setString(
        _keyLogs, jsonEncode(logs.map((l) => l.toMap()).toList()));
  }

  Future<void> deleteLogsByPlantAndDate(String plantId, DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final logs = await _getAllLogs();
    logs.removeWhere((l) =>
        l.plantId == plantId &&
        l.date.year == date.year &&
        l.date.month == date.month &&
        l.date.day == date.day);
    await prefs.setString(
        _keyLogs, jsonEncode(logs.map((l) => l.toMap()).toList()));
  }

  // ─────────────────────────────────────────
  // Note 操作
  // ─────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getAllNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyNotes);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List;
    final notes = list
        .map((e) => Map<String, dynamic>.from(e))
        .toList()
      ..sort((a, b) => (b['updatedAt'] as String).compareTo(a['updatedAt'] as String));
    return notes;
  }

  Future<void> insertNote(Note note) async {
    final prefs = await SharedPreferences.getInstance();
    final notes = await getAllNotes();
    notes.removeWhere((n) => n['id'] == note.id);
    notes.add(note.toMap());
    await prefs.setString(_keyNotes, jsonEncode(notes));
  }

  Future<void> updateNote(Note note) async {
    await insertNote(note);
  }

  Future<void> deleteNote(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final notes = await getAllNotes();
    notes.removeWhere((n) => n['id'] == id);
    await prefs.setString(_keyNotes, jsonEncode(notes));
  }

  /// ノートの plantIds から指定IDを除去する（植物削除時に呼ぶ）
  Future<void> removePlantIdFromNotes(String plantId) async {
    final prefs = await SharedPreferences.getInstance();
    final notes = await getAllNotes();
    final updated = notes.map((n) {
      final ids = (n['plantIds'] as String? ?? '')
          .split('|')
          .where((id) => id.isNotEmpty && id != plantId)
          .toList();
      return {...n, 'plantIds': ids.join('|')};
    }).toList();
    await prefs.setString(_keyNotes, jsonEncode(updated));
  }
}
