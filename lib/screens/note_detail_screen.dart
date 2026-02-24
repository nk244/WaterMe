import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../providers/plant_provider.dart';
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
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => AddEditNoteScreen(note: note)),
            ),
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
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('キャンセル')),
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('削除')),
                  ],
                ),
              );
              if (confirmed == true) {
                await context.read<NoteProvider>().deleteNote(note.id);
                if (context.mounted && Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 植物チップ
            if (note.plantIds.isNotEmpty)
              Consumer<PlantProvider>(builder: (context, plantProv, _) {
                final names = plantProv.plants
                    .where((p) => note.plantIds.contains(p.id))
                    .map((p) => p.name)
                    .toList();
                if (names.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: names
                        .map((name) => Chip(
                              label: Text(name),
                              avatar: const Icon(Icons.eco, size: 14),
                              visualDensity: VisualDensity.compact,
                            ))
                        .toList(),
                  ),
                );
              }),

            // 内容
            if (note.content != null && note.content!.isNotEmpty)
              Text(note.content!, style: Theme.of(context).textTheme.bodyLarge),

            // 画像
            if (note.imagePaths.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: note.imagePaths.map((p) {
                  final img = kIsWeb
                      ? Image.network(p, width: 120, height: 120, fit: BoxFit.cover)
                      : Image.file(File(p), width: 120, height: 120, fit: BoxFit.cover);
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: img,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
