import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';
import '../services/database_service.dart';
import '../services/web_storage_service.dart';

class NoteProvider with ChangeNotifier {
  final DatabaseService? _db = kIsWeb ? null : DatabaseService();
  final WebStorageService? _web = kIsWeb ? WebStorageService() : null;
  List<Note> _notes = [];
  bool _isLoading = false;

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;

  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (kIsWeb) {
        final maps = await _web!.getAllNotes();
        _notes = maps.map((m) => Note.fromMap(Map<String, dynamic>.from(m))).toList();
      } else {
        _notes = await _db!.getAllNotes();
      }
    } catch (e) {
      debugPrint('Error loading notes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addNote({required String title, String? content, List<String>? plantIds, List<String>? imagePaths}) async {
    final now = DateTime.now();
    final note = Note(
      id: const Uuid().v4(),
      title: title,
      content: content,
      plantIds: plantIds ?? [],
      imagePaths: imagePaths ?? [],
      createdAt: now,
      updatedAt: now,
    );

    if (kIsWeb) {
      await _web!.insertNote(note);
    } else {
      await _db!.insertNote(note);
    }

    await loadNotes();
  }

  Future<void> updateNote(Note note) async {
    if (kIsWeb) {
      await _web!.updateNote(note);
    } else {
      await _db!.updateNote(note);
    }
    await loadNotes();
  }

  Future<void> deleteNote(String id) async {
    if (kIsWeb) {
      await _web!.deleteNote(id);
    } else {
      await _db!.deleteNote(id);
    }
    await loadNotes();
  }
}
