import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../providers/note_provider.dart';
import '../providers/plant_provider.dart';
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
    Future.microtask(() {
      context.read<NoteProvider>().loadNotes();
      context.read<PlantProvider>().loadPlants();
    });
  }

  /// ノートを日付（createdAt の日付部分）でグループ化して、降順で返す
  Map<String, List<Note>> _groupByDate(List<Note> notes) {
    final Map<String, List<Note>> grouped = {};
    for (final note in notes) {
      final key = DateFormat('yyyy-MM-dd').format(note.createdAt);
      grouped.putIfAbsent(key, () => []).add(note);
    }
    // 各グループ内を新しい順に並べる
    for (final key in grouped.keys) {
      grouped[key]!.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    // キー（日付文字列）を降順に並べた LinkedHashMap 相当を返す
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    return {for (final k in sortedKeys) k: grouped[k]!};
  }

  String _formatDateHeader(String dateKey) {
    final dt = DateTime.parse(dateKey);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final d = DateTime(dt.year, dt.month, dt.day);

    if (d == today) return '今日  ${DateFormat('MM月dd日 (E)', 'ja').format(dt)}';
    if (d == yesterday) return '昨日  ${DateFormat('MM月dd日 (E)', 'ja').format(dt)}';
    return DateFormat('yyyy年MM月dd日 (E)', 'ja').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ノート'),
      ),
      body: Consumer2<NoteProvider, PlantProvider>(
        builder: (context, noteProvider, plantProvider, _) {
          if (noteProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (noteProvider.notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu_book_outlined,
                      size: 72,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.4)),
                  const SizedBox(height: 16),
                  Text('まだノートがありません',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('右下の ＋ ボタンから記録しましょう',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            );
          }

          final grouped = _groupByDate(noteProvider.notes);
          final dateKeys = grouped.keys.toList();

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
            itemCount: dateKeys.length,
            itemBuilder: (context, i) {
              final key = dateKeys[i];
              final dayNotes = grouped[key]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── 日付ヘッダー ──
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _formatDateHeader(key),
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Divider(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── その日のノート一覧（タイムライン風） ──
                  ...dayNotes.asMap().entries.map((entry) {
                    final isLast = entry.key == dayNotes.length - 1;
                    final note = entry.value;

                    // 関連植物名
                    final plantNames = plantProvider.plants
                        .where((p) => note.plantIds.contains(p.id))
                        .map((p) => p.name)
                        .toList();

                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // タイムライン縦線 + 丸
                          SizedBox(
                            width: 32,
                            child: Column(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  margin: const EdgeInsets.only(top: 14),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                if (!isLast)
                                  Expanded(
                                    child: Center(
                                      child: Container(
                                        width: 2,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outlineVariant,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          // カード
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
                              child: Card(
                                margin: EdgeInsets.zero,
                                elevation: 1,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => NoteDetailScreen(note: note),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // 時刻 + タイトル
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              DateFormat('HH:mm').format(note.createdAt),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelSmall
                                                  ?.copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface
                                                        .withOpacity(0.5),
                                                  ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                note.title,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall
                                                    ?.copyWith(fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),

                                        // 内容プレビュー
                                        if (note.content != null &&
                                            note.content!.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            note.content!,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                        ],

                                        // 植物チップ
                                        if (plantNames.isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Wrap(
                                            spacing: 4,
                                            runSpacing: 2,
                                            children: plantNames
                                                .map((name) => Chip(
                                                      label: Text(name),
                                                      avatar: const Icon(Icons.eco, size: 12),
                                                      visualDensity: VisualDensity.compact,
                                                      padding: EdgeInsets.zero,
                                                      labelStyle: Theme.of(context)
                                                          .textTheme
                                                          .labelSmall,
                                                      materialTapTargetSize:
                                                          MaterialTapTargetSize.shrinkWrap,
                                                    ))
                                                .toList(),
                                          ),
                                        ],

                                        // 画像サムネイル
                                        if (note.imagePaths.isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Icon(Icons.photo_library_outlined,
                                                  size: 14,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface
                                                      .withOpacity(0.5)),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${note.imagePaths.length} 枚',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelSmall
                                                    ?.copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurface
                                                          .withOpacity(0.5),
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddEditNoteScreen()),
        ),
        child: const Icon(Icons.edit_outlined),
      ),
    );
  }
}
