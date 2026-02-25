import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/plant.dart';
import '../models/log_entry.dart';
import '../models/note.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      throw UnsupportedError(
        'Database is not supported on the web. '
        'Please use Android or iOS for full functionality.',
      );
    }
    String path = join(await getDatabasesPath(), 'water_me.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE notes(
              id TEXT PRIMARY KEY,
              title TEXT NOT NULL,
              content TEXT,
              imagePaths TEXT,
              plantIds TEXT,
              createdAt TEXT NOT NULL,
              updatedAt TEXT NOT NULL
            )
          ''');
        }

        if (oldVersion < 3) {
          // add plantIds column to notes (for older DBs)
          try {
            await db.execute('ALTER TABLE notes ADD COLUMN plantIds TEXT');
          } catch (_) {
            // ignore if column already exists
          }
        }
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE plants(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        variety TEXT,
        purchaseDate TEXT,
        purchaseLocation TEXT,
        imagePath TEXT,
        wateringIntervalDays INTEGER,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE logs(
        id TEXT PRIMARY KEY,
        plantId TEXT NOT NULL,
        type TEXT NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (plantId) REFERENCES plants (id) ON DELETE CASCADE
      )
    ''');

    // Notes table for standalone notes/diary entries
    await db.execute('''
      CREATE TABLE notes(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT,
        imagePaths TEXT,
        plantIds TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
  }

  // Plant CRUD operations
  Future<void> insertPlant(Plant plant) async {
    final db = await database;
    await db.insert('plants', plant.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Plant>> getAllPlants() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('plants',
        orderBy: 'updatedAt DESC');
    return List.generate(maps.length, (i) => Plant.fromMap(maps[i]));
  }

  Future<Plant?> getPlant(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'plants',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Plant.fromMap(maps.first);
  }

  Future<void> updatePlant(Plant plant) async {
    final db = await database;
    await db.update(
      'plants',
      plant.toMap(),
      where: 'id = ?',
      whereArgs: [plant.id],
    );
  }

  Future<void> deletePlant(String id) async {
    final db = await database;
    await db.delete(
      'plants',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Log CRUD operations
  Future<void> insertLog(LogEntry log) async {
    final db = await database;
    await db.insert('logs', log.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<LogEntry>> getLogsByPlant(String plantId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'logs',
      where: 'plantId = ?',
      whereArgs: [plantId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => LogEntry.fromMap(maps[i]));
  }

  Future<List<LogEntry>> getLogsByPlantAndType(
      String plantId, LogType type) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'logs',
      where: 'plantId = ? AND type = ?',
      whereArgs: [plantId, type.name],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => LogEntry.fromMap(maps[i]));
  }

  Future<void> updateLog(LogEntry log) async {
    final db = await database;
    await db.update(
      'logs',
      log.toMap(),
      where: 'id = ?',
      whereArgs: [log.id],
    );
  }

  Future<void> deleteLog(String id) async {
    final db = await database;
    await db.delete(
      'logs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Notes CRUD operations
  Future<void> insertNote(Note note) async {
    final db = await database;
    await db.insert('notes', note.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Note>> getAllNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('notes', orderBy: 'updatedAt DESC');
    return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
  }

  Future<void> updateNote(Note note) async {
    final db = await database;
    await db.update('notes', note.toMap(), where: 'id = ?', whereArgs: [note.id]);
  }

  Future<void> deleteNote(String id) async {
    final db = await database;
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
