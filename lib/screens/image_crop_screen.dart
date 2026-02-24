import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ImageCropScreen extends StatefulWidget {
  final String imagePath;
  const ImageCropScreen({super.key, required this.imagePath});

  @override
  State<ImageCropScreen> createState() => _ImageCropScreenState();
}

class _ImageCropScreenState extends State<ImageCropScreen> {
  final _controller = CropController();
  bool _isCropping = false;

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _saveCropped(Uint8List cropped) async {
    setState(() => _isCropping = true);
    try {
      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'crop_${path.basename(widget.imagePath)}';
      final outFile = File('${dir.path}/$fileName');
      await outFile.writeAsBytes(cropped);
      if (mounted) Navigator.of(context).pop(outFile.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('保存に失敗しました: $e')));
      }
    } finally {
      if (mounted) setState(() => _isCropping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('画像をトリミング'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _isCropping
                ? null
                : () {
                    _controller.crop();
                  },
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: Crop(
              controller: _controller,
              image: File(widget.imagePath).readAsBytesSync(),
              onCropped: _saveCropped,
              aspectRatio: 1,
              withCircleUi: false,
            ),
          ),
          if (_isCropping)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
