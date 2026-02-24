import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/note_provider.dart';
import 'add_edit_note_screen.dart';
import 'note_detail_screen.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<NoteProvider>().loadNotes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ノート'),
      ),
      body: Consumer<NoteProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator());
          if (provider.notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.note_outlined, size: 64, color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text('ノートがありません', style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: provider.notes.length,
            itemBuilder: (context, index) {
              final note = provider.notes[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ListTile(
                  title: Text(note.title),
                  subtitle: note.content != null ? Text(note.content!, maxLines: 1, overflow: TextOverflow.ellipsis) : null,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => NoteDetailScreen(note: note))),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddEditNoteScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }
}
