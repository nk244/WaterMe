import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'image_crop_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../providers/plant_provider.dart';
import '../models/plant.dart';
import '../widgets/plant_image_widget.dart';

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
  Uint8List? _imageBytes; // Web用: トリミング後のバイト列
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

  Future<void> _showImageSourceOptions() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('カメラで撮影'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('ギャラリーから選択'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source, maxWidth: 2048, maxHeight: 2048);
      if (pickedFile == null) return;

      // Web・モバイル共通でトリミング画面へ遷移
      final cropResult = await Navigator.of(context).push<CropResult?>(
        MaterialPageRoute(
          builder: (_) => kIsWeb
              ? ImageCropScreen.web(xFile: pickedFile)
              : ImageCropScreen.mobile(imagePath: pickedFile.path),
        ),
      );

      // ユーザーが「戻る」を押した場合はキャンセル扱い
      if (cropResult == null) return;

      if (kIsWeb && cropResult.bytes != null) {
        // Web: バイト列をメモリに保持。表示はUint8Listから行う
        setState(() {
          _imagePath = pickedFile.path; // XFileのpathはBlob URLとして使用可
          _imageBytes = cropResult.bytes;
        });
      } else if (cropResult.filePath != null) {
        // モバイル: 保存済みファイルパスを使用
        setState(() => _imagePath = cropResult.filePath);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('画像の取得に失敗しました: $e')),
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

      // Web: トリミング済みバイト列を Base64 data URL に変換して imagePath として保存
      String? effectiveImagePath = _imagePath;
      if (kIsWeb && _imageBytes != null) {
        final base64 = base64Encode(_imageBytes!);
        effectiveImagePath = 'data:image/jpeg;base64,$base64';
      }
      
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
          imagePath: effectiveImagePath,
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
          imagePath: effectiveImagePath,
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
                onTap: _showImageSourceOptions,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: (_imageBytes != null || _imagePath != null)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: _imageBytes != null
                              // Web: トリミング済みバイト列から直接表示
                              ? Image.memory(
                                  _imageBytes!,
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.cover,
                                )
                              : PlantImageWidget(
                                  imagePath: _imagePath,
                                  width: 150,
                                  height: 150,
                                  borderRadius: BorderRadius.zero,
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
