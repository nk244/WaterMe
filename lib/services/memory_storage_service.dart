import '../models/plant.dart';
import '../models/log_entry.dart';
import '../models/diary_entry.dart';
import '../data/test_data_generator.dart';

class MemoryStorageService {
  static final MemoryStorageService _instance = MemoryStorageService._internal();
  
  factory MemoryStorageService() {
    return _instance;
  }

  MemoryStorageService._internal() {
    _initializeTestData();
  }

  final List<Plant> _plants = [];
  final List<LogEntry> _logs = [];
  final List<DiaryEntry> _diaries = [];
  final List _notes = [];
  bool _isInitialized = false;

  void _initializeTestData() {
    if (_isInitialized) return;
    _isInitialized = true;

    // テストデータ生成クラスを使用してデータを作成
    final testPlants = TestDataGenerator.generateTestPlants();
    final testLogs = TestDataGenerator.generateTestLogs(testPlants);

    _plants.addAll(testPlants);
    _logs.addAll(testLogs);
  }

  // Plant operations
  Future<void> insertPlant(Plant plant) async {
    _plants.removeWhere((p) => p.id == plant.id);
    _plants.add(plant);
  }

  Future<List<Plant>> getAllPlants() async {
    return List.from(_plants)..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<Plant?> getPlant(String id) async {
    try {
      return _plants.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> updatePlant(Plant plant) async {
    _plants.removeWhere((p) => p.id == plant.id);
    _plants.add(plant);
  }

  Future<void> deletePlant(String id) async {
    _plants.removeWhere((p) => p.id == id);
    _logs.removeWhere((l) => l.plantId == id);
    _diaries.removeWhere((d) => d.plantId == id);
  }

  // Log operations
  Future<void> insertLog(LogEntry log) async {
    _logs.removeWhere((l) => l.id == log.id);
    _logs.add(log);
  }

  Future<List<LogEntry>> getLogsByPlant(String plantId) async {
    return _logs.where((l) => l.plantId == plantId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<List<LogEntry>> getLogsByPlantAndType(String plantId, LogType type) async {
    return _logs
        .where((l) => l.plantId == plantId && l.type == type)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> updateLog(LogEntry log) async {
    _logs.removeWhere((l) => l.id == log.id);
    _logs.add(log);
  }

  Future<void> deleteLog(String id) async {
    _logs.removeWhere((l) => l.id == id);
  }

  // Diary operations
  Future<void> insertDiary(DiaryEntry diary) async {
    _diaries.removeWhere((d) => d.id == diary.id);
    _diaries.add(diary);
  }

  Future<List<DiaryEntry>> getDiariesByPlant(String plantId) async {
    return _diaries.where((d) => d.plantId == plantId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> updateDiary(DiaryEntry diary) async {
    _diaries.removeWhere((d) => d.id == diary.id);
    _diaries.add(diary);
  }

  Future<void> deleteDiary(String id) async {
    _diaries.removeWhere((d) => d.id == id);
  }

  // Note operations
  Future<void> insertNote(note) async {
    _notes.removeWhere((n) => n['id'] == note.id);
    _notes.add(note.toMap());
  }

  Future<List> getAllNotes() async {
    return List.from(_notes)..sort((a, b) => b['updatedAt'].compareTo(a['updatedAt']));
  }

  Future<void> updateNote(note) async {
    _notes.removeWhere((n) => n['id'] == note.id);
    _notes.add(note.toMap());
  }

  Future<void> deleteNote(String id) async {
    _notes.removeWhere((n) => n['id'] == id);
  }

  Future<void> close() async {
    // No-op for memory storage
  }
}
