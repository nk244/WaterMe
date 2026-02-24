import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import 'add_edit_note_screen.dart';
import '../providers/note_provider.dart';

class NoteDetailScreen extends StatelessWidget {
  final Note note;
  const NoteDetailScreen({required this.note, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(note.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddEditNoteScreen(note: note))),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('削除の確認'),
                  content: const Text('このノートを削除しますか？'),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('キャンセル')),
                    TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('削除')),
                  ],
                ),
              );

              if (confirmed == true) {
                await context.read<NoteProvider>().deleteNote(note.id);
                if (Navigator.of(context).canPop()) Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (note.content != null && note.content!.isNotEmpty)
                Text(note.content!),
            ],
          ),
        ),
      ),
    );
  }
}
