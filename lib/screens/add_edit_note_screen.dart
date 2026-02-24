import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import '../providers/plant_provider.dart';
import '../models/note.dart';
import '../providers/note_provider.dart';

class AddEditNoteScreen extends StatefulWidget {
  final Note? note;
  const AddEditNoteScreen({this.note, super.key});

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  List<String> _selectedPlantIds = [];
  List<String> _selectedImagePaths = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _selectedPlantIds = widget.note?.plantIds ?? [];
    _selectedImagePaths = widget.note?.imagePaths ?? [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<NoteProvider>();

    if (widget.note == null) {
      await provider.addNote(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        plantIds: _selectedPlantIds,
        imagePaths: _selectedImagePaths,
      );
    } else {
      final updated = widget.note!.copyWith(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        plantIds: _selectedPlantIds,
        imagePaths: _selectedImagePaths,
        updatedAt: DateTime.now(),
      );
      await provider.updateNote(updated);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'ノート作成' : 'ノート編集'),
        actions: [
          IconButton(onPressed: _save, icon: const Icon(Icons.save)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'タイトル'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'タイトルを入力してください' : null,
              ),
              const SizedBox(height: 12),
              // Plant selection
              Consumer<PlantProvider>(builder: (context, plantProv, _) {
                return ListTile(
                  title: const Text('関連植物'),
                  subtitle: Text(_selectedPlantIds.isEmpty
                      ? '選択されていません'
                      : '${_selectedPlantIds.length} 個選択済み'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _selectPlants(context, plantProv),
                );
              }),
              const SizedBox(height: 8),
              // Image attachments
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ..._selectedImagePaths.map((p) => _buildImageThumb(p)),
                    IconButton(
                      onPressed: _showImageSourceOptions,
                      icon: const Icon(Icons.add_a_photo),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(labelText: '内容'),
                  maxLines: null,
                  expands: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageThumb(String path) {
    final widget = kIsWeb
        ? Image.network(path, width: 72, height: 72, fit: BoxFit.cover)
        : Image.file(File(path), width: 72, height: 72, fit: BoxFit.cover);

    return Stack(
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(8), child: widget),
        Positioned(
          right: 0,
          top: 0,
          child: InkWell(
            onTap: () => setState(() => _selectedImagePaths.remove(path)),
            child: const CircleAvatar(radius: 10, child: Icon(Icons.close, size: 12)),
          ),
        )
      ],
    );
  }

  Future<void> _selectPlants(BuildContext context, PlantProvider plantProv) async {
    // Ensure plants are loaded
    if (plantProv.plants.isEmpty) await plantProv.loadPlants();

    final allPlants = plantProv.plants;
    final tempSelected = List<String>.from(_selectedPlantIds);

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('関連植物を選択'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              children: allPlants.map((p) {
                final checked = tempSelected.contains(p.id);
                return CheckboxListTile(
                  value: checked,
                  title: Text(p.name),
                  onChanged: (v) {
                    setState(() {
                      if (v == true) {
                        tempSelected.add(p.id);
                      } else {
                        tempSelected.remove(p.id);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('キャンセル')),
            TextButton(
                onPressed: () {
                  setState(() => _selectedPlantIds = tempSelected);
                  Navigator.of(ctx).pop();
                },
                child: const Text('OK')),
          ],
        );
      },
    );
  }

  void _showImageSourceOptions() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('カメラ'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('ギャラリー'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picker = ImagePicker();
    if (source == ImageSource.camera) {
      final x = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
      if (x != null) setState(() => _selectedImagePaths.add(x.path));
    } else {
      final xs = await picker.pickMultiImage(imageQuality: 80);
      if (xs != null && xs.isNotEmpty) setState(() => _selectedImagePaths.addAll(xs.map((e) => e.path)));
    }
  }
}
