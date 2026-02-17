import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../providers/plant_provider.dart';
import '../models/plant.dart';

class AddPlantScreen extends StatefulWidget {
  final Plant? plant;

  const AddPlantScreen({super.key, this.plant});

  @override
  State<AddPlantScreen> createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _varietyController = TextEditingController();
  final _purchaseLocationController = TextEditingController();
  
  DateTime? _purchaseDate;
  int? _wateringInterval;
  String? _imagePath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.plant != null) {
      _nameController.text = widget.plant!.name;
      _varietyController.text = widget.plant!.variety ?? '';
      _purchaseLocationController.text = widget.plant!.purchaseLocation ?? '';
      _purchaseDate = widget.plant!.purchaseDate;
      _wateringInterval = widget.plant!.wateringIntervalDays;
      _imagePath = widget.plant!.imagePath;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _varietyController.dispose();
    _purchaseLocationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      
      if (pickedFile != null) {
        if (kIsWeb) {
          // For web, just use the path directly
          setState(() {
            _imagePath = pickedFile.path;
          });
        } else {
          // For mobile, copy to app directory
          final appDir = await getApplicationDocumentsDirectory();
          final fileName = path.basename(pickedFile.path);
          final savedImage = await File(pickedFile.path).copy('${appDir.path}/$fileName');
          
          setState(() {
            _imagePath = savedImage.path;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('画像の選択に失敗しました: $e')),
        );
      }
    }
  }

  Future<void> _savePlant() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final plantProvider = context.read<PlantProvider>();
      
      if (widget.plant == null) {
        // Add new plant
        await plantProvider.addPlant(
          name: _nameController.text.trim(),
          variety: _varietyController.text.trim().isEmpty 
              ? null 
              : _varietyController.text.trim(),
          purchaseDate: _purchaseDate,
          purchaseLocation: _purchaseLocationController.text.trim().isEmpty
              ? null
              : _purchaseLocationController.text.trim(),
          imagePath: _imagePath,
          wateringIntervalDays: _wateringInterval,
        );
      } else {
        // Update existing plant
        final updatedPlant = widget.plant!.copyWith(
          name: _nameController.text.trim(),
          variety: _varietyController.text.trim().isEmpty 
              ? null 
              : _varietyController.text.trim(),
          purchaseDate: _purchaseDate,
          purchaseLocation: _purchaseLocationController.text.trim().isEmpty
              ? null
              : _purchaseLocationController.text.trim(),
          imagePath: _imagePath,
          wateringIntervalDays: _wateringInterval,
        );
        await plantProvider.updatePlant(updatedPlant);
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラーが発生しました: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plant == null ? '植物を追加' : '植物を編集'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FilledButton.icon(
                onPressed: _savePlant,
                icon: const Icon(Icons.check),
                label: const Text('保存'),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Image picker
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _imagePath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: kIsWeb
                              ? Image.network(
                                  _imagePath!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          size: 48,
                                          color: Theme.of(context).colorScheme.error,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '画像を読み込めません',
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ],
                                    );
                                  },
                                )
                              : File(_imagePath!).existsSync()
                                  ? Image.file(
                                      File(_imagePath!),
                                      fit: BoxFit.cover,
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.broken_image,
                                          size: 48,
                                          color: Theme.of(context).colorScheme.error,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'ファイルが見つかりません',
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 48,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '写真を追加',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Plant name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '植物名',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.eco),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '植物名を入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Variety
            TextFormField(
              controller: _varietyController,
              decoration: const InputDecoration(
                labelText: '品種名（任意）',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
            ),
            const SizedBox(height: 16),
            
            // Purchase date
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('購入日'),
              subtitle: Text(
                _purchaseDate == null
                    ? '未設定'
                    : '${_purchaseDate!.year}年${_purchaseDate!.month}月${_purchaseDate!.day}日',
              ),
              trailing: _purchaseDate != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _purchaseDate = null;
                        });
                      },
                    )
                  : null,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _purchaseDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _purchaseDate = date;
                  });
                }
              },
            ),
            const Divider(),
            
            // Purchase location
            TextFormField(
              controller: _purchaseLocationController,
              decoration: const InputDecoration(
                labelText: '購入先（任意）',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.store),
              ),
            ),
            const SizedBox(height: 16),
            
            // Watering interval
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.water_drop),
              title: const Text('水やり間隔'),
              subtitle: Text(
                _wateringInterval == null
                    ? '未設定'
                    : '$_wateringInterval日ごと',
              ),
              trailing: _wateringInterval != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _wateringInterval = null;
                        });
                      },
                    )
                  : null,
              onTap: () async {
                final result = await showDialog<int>(
                  context: context,
                  builder: (context) => _WateringIntervalDialog(
                    initialValue: _wateringInterval,
                  ),
                );
                if (result != null) {
                  setState(() {
                    _wateringInterval = result;
                  });
                }
              },
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}

class _WateringIntervalDialog extends StatefulWidget {
  final int? initialValue;

  const _WateringIntervalDialog({this.initialValue});

  @override
  State<_WateringIntervalDialog> createState() => _WateringIntervalDialogState();
}

class _WateringIntervalDialogState extends State<_WateringIntervalDialog> {
  late int _days;

  @override
  void initState() {
    super.initState();
    _days = widget.initialValue ?? 3;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('水やり間隔'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$_days日ごと', style: Theme.of(context).textTheme.headlineSmall),
          Slider(
            value: _days.toDouble(),
            min: 1,
            max: 30,
            divisions: 29,
            label: '$_days日',
            onChanged: (value) {
              setState(() {
                _days = value.toInt();
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_days),
          child: const Text('設定'),
        ),
      ],
    );
  }
}
