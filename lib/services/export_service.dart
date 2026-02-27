import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/plant.dart';
import '../models/log_entry.dart';
import '../models/note.dart';
import 'database_service.dart';

/// データのエクスポート / インポートを担うサービス
///
/// JSON 形式で Plants / Logs / Notes を一括保存・復元する。
/// Web ではファイルの直接保存が困難なため、エクスポートはクリップボード向け JSON を返す。
class ExportService {
  static final ExportService _instance = ExportService._internal();
  factory ExportService() => _instance;
  ExportService._internal();

  final _db = DatabaseService();

  // ── エクスポート ──────────────────────────────────────────

  /// 全データを JSON 文字列に変換して返す
  Future<String> exportToJson() async {
    final plants = await _db.getAllPlants();
    final allLogs = <LogEntry>[];
    for (final plant in plants) {
      final logs = await _db.getLogsByPlant(plant.id);
      allLogs.addAll(logs);
    }
    final notes = await _db.getAllNotes();

    final data = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'plants': plants.map((p) => p.toMap()).toList(),
      'logs': allLogs.map((l) => l.toMap()).toList(),
      'notes': notes.map((n) => n.toMap()).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// JSON をユーザーが選択した保存先に書き込む（モバイル専用）
  ///
  /// キャンセル時は null を返す。Web 環境では [UnsupportedError] をスローする。
  Future<String?> exportToFile() async {
    if (kIsWeb) {
      throw UnsupportedError('Web 環境ではファイル保存に対応していません。');
    }

    final fileName =
        'waterme_backup_${DateTime.now().millisecondsSinceEpoch}.json';

    // ユーザーに保存先フォルダを選択させる
    final savePath = await FilePicker.platform.saveFile(
      dialogTitle: 'エクスポート先を選択',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    // キャンセル時
    if (savePath == null) return null;

    final jsonStr = await exportToJson();
    final file = File(savePath);
    await file.writeAsString(jsonStr, encoding: utf8);
    return file.path;
  }

  // ── インポート ────────────────────────────────────────────

  /// ファイルピッカーでファイルを選択して JSON をインポートする
  ///
  /// 戻り値: 成功した場合は [ImportResult]、キャンセルの場合は null
  Future<ImportResult?> importFromFilePicker() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: kIsWeb, // Web ではバイトを直接読む
    );

    if (result == null || result.files.isEmpty) return null;

    String jsonStr;
    if (kIsWeb) {
      // Web: bytes から文字列に変換
      final bytes = result.files.first.bytes;
      if (bytes == null) return null;
      jsonStr = utf8.decode(bytes);
    } else {
      // モバイル: ファイルパスから読み込む
      final path = result.files.first.path;
      if (path == null) return null;
      jsonStr = await File(path).readAsString(encoding: utf8);
    }

    return _importFromJson(jsonStr);
  }

  /// JSON 文字列からデータを復元する（既存データは保持して追加/上書き）
  Future<ImportResult> _importFromJson(String jsonStr) async {
    final Map<String, dynamic> data =
        jsonDecode(jsonStr) as Map<String, dynamic>;

    // バージョン確認（将来の互換対応用）
    final version = data['version'] as int? ?? 1;
    if (version > 1) {
      throw FormatException('未対応のバックアップバージョン: $version');
    }

    int plantCount = 0;
    int logCount = 0;
    int noteCount = 0;

    // 植物をインポート
    final plantsJson = data['plants'] as List<dynamic>? ?? [];
    for (final p in plantsJson) {
      final plant = Plant.fromMap(Map<String, dynamic>.from(p as Map));
      await _db.insertPlant(plant);
      plantCount++;
    }

    // ログをインポート
    final logsJson = data['logs'] as List<dynamic>? ?? [];
    for (final l in logsJson) {
      final log = LogEntry.fromMap(Map<String, dynamic>.from(l as Map));
      await _db.insertLog(log);
      logCount++;
    }

    // ノートをインポート
    final notesJson = data['notes'] as List<dynamic>? ?? [];
    for (final n in notesJson) {
      final note = Note.fromMap(Map<String, dynamic>.from(n as Map));
      await _db.insertNote(note);
      noteCount++;
    }

    return ImportResult(
      plantCount: plantCount,
      logCount: logCount,
      noteCount: noteCount,
    );
  }
}

/// インポート結果を保持するデータクラス
class ImportResult {
  final int plantCount;
  final int logCount;
  final int noteCount;

  const ImportResult({
    required this.plantCount,
    required this.logCount,
    required this.noteCount,
  });

  @override
  String toString() =>
      '植物: $plantCount件、ログ: $logCount件、ノート: $noteCount件';
}
