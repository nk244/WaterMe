import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// トリミング結果を表すシールドクラス。
/// Web では [bytes] のみ、モバイルでは [filePath] のみ使用。
class CropResult {
  final String? filePath;
  final Uint8List? bytes;
  const CropResult.path(this.filePath) : bytes = null;
  const CropResult.web(this.bytes) : filePath = null;
}

class ImageCropScreen extends StatefulWidget {
  /// モバイル用: 画像のファイルパス
  final String? imagePath;
  /// Web用: ImagePickerで取得したXFile
  final XFile? xFile;

  const ImageCropScreen.mobile({super.key, required this.imagePath})
      : xFile = null;

  const ImageCropScreen.web({super.key, required this.xFile})
      : imagePath = null;

  @override
  State<ImageCropScreen> createState() => _ImageCropScreenState();
}

class _ImageCropScreenState extends State<ImageCropScreen> {
  final _controller = CropController();
  bool _isCropping = false;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    Uint8List bytes;
    if (kIsWeb && widget.xFile != null) {
      bytes = await widget.xFile!.readAsBytes();
    } else if (widget.imagePath != null) {
      bytes = await File(widget.imagePath!).readAsBytes();
    } else {
      return;
    }
    if (mounted) setState(() => _imageBytes = bytes);
  }

  Future<void> _onCropped(Uint8List cropped) async {
    setState(() => _isCropping = true);
    try {
      if (kIsWeb) {
        // Web: バイト列をそのまま返す
        if (mounted) Navigator.of(context).pop(CropResult.web(cropped));
      } else {
        // モバイル: アプリドキュメントディレクトリに保存してパスを返す
        final dir = await getApplicationDocumentsDirectory();
        final fileName = 'crop_${path.basename(widget.imagePath!)}';
        final outFile = File('${dir.path}/$fileName');
        await outFile.writeAsBytes(cropped);
        if (mounted) Navigator.of(context).pop(CropResult.path(outFile.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('保存に失敗しました: $e')));
      }
    } finally {
      if (mounted) setState(() => _isCropping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('画像をトリミング'),
        backgroundColor: Colors.black54,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'トリミングを確定',
            onPressed: (_isCropping || _imageBytes == null)
                ? null
                : () => _controller.crop(),
          ),
        ],
      ),
      body: _imageBytes == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Crop(
                  controller: _controller,
                  image: _imageBytes!,
                  onCropped: _onCropped,
                  aspectRatio: 1,
                  withCircleUi: false,
                  interactive: true,
                ),
                if (_isCropping)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
    );
  }
}
