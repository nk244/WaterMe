import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';
import '../services/database_service.dart';
import '../services/memory_storage_service.dart';

class NoteProvider with ChangeNotifier {
  final _db = kIsWeb ? null : DatabaseService();
  final _memory = kIsWeb ? MemoryStorageService() : null;
  List<Note> _notes = [];
  bool _isLoading = false;

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;

  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (kIsWeb) {
        final maps = await _memory!.getAllNotes();
        _notes = maps.map((m) => Note.fromMap(m)).toList();
      } else {
        final maps = await _db!.getAllNotes();
        _notes = maps.map((m) => Note.fromMap(m)).toList();
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
      await _memory!.insertNote(note);
    } else {
      await _db!.insertNote(note);
    }

    await loadNotes();
  }

  Future<void> updateNote(Note note) async {
    if (kIsWeb) {
      await _memory!.updateNote(note);
    } else {
      await _db!.updateNote(note);
    }
    await loadNotes();
  }

  Future<void> deleteNote(String id) async {
    if (kIsWeb) {
      await _memory!.deleteNote(id);
    } else {
      await _db!.deleteNote(id);
    }
    await loadNotes();
  }
}
