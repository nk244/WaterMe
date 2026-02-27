import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/plant.dart';
import '../models/log_entry.dart';
import '../models/note.dart';
import '../models/app_settings.dart';
import '../services/database_service.dart';
import '../services/web_storage_service.dart';

class PlantProvider with ChangeNotifier {
  final DatabaseService? _db = kIsWeb ? null : DatabaseService();
  final WebStorageService? _web = kIsWeb ? WebStorageService() : null;
  List<Plant> _plants = [];
  bool _isLoading = false;
  final Map<String, DateTime?> _nextWateringCache = {};

  List<Plant> get plants => _plants;
  bool get isLoading => _isLoading;

  Future<void> loadPlants() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (kIsWeb) {
        _plants = await _web!.getAllPlants();
      } else {
        _plants = await _db!.getAllPlants();
      }
      
      // Update next watering date cache
      for (var plant in _plants) {
        _nextWateringCache[plant.id] = await calculateNextWateringDate(plant.id);
      }
    } catch (e) {
      debugPrint('Error loading plants: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get sorted plants based on settings
  List<Plant> getSortedPlants(PlantSortOrder sortOrder, List<String> customOrder) {
    final plantsCopy = List<Plant>.from(_plants);
    
    switch (sortOrder) {
      case PlantSortOrder.nameAsc:
        plantsCopy.sort((a, b) => a.name.compareTo(b.name));
        break;
      case PlantSortOrder.nameDesc:
        plantsCopy.sort((a, b) => b.name.compareTo(a.name));
        break;
      case PlantSortOrder.purchaseDateDesc:
        plantsCopy.sort((a, b) {
          if (a.purchaseDate == null && b.purchaseDate == null) return 0;
          if (a.purchaseDate == null) return 1;
          if (b.purchaseDate == null) return -1;
          return b.purchaseDate!.compareTo(a.purchaseDate!);
        });
        break;
      case PlantSortOrder.purchaseDateAsc:
        plantsCopy.sort((a, b) {
          if (a.purchaseDate == null && b.purchaseDate == null) return 0;
          if (a.purchaseDate == null) return 1;
          if (b.purchaseDate == null) return -1;
          return a.purchaseDate!.compareTo(b.purchaseDate!);
        });
        break;
      case PlantSortOrder.createdAtAsc:
        plantsCopy.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case PlantSortOrder.createdAtDesc:
        plantsCopy.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case PlantSortOrder.custom:
        if (customOrder.isNotEmpty) {
          plantsCopy.sort((a, b) {
            final aIndex = customOrder.indexOf(a.id);
            final bIndex = customOrder.indexOf(b.id);
            if (aIndex == -1 && bIndex == -1) return 0;
            if (aIndex == -1) return 1;
            if (bIndex == -1) return -1;
            return aIndex.compareTo(bIndex);
          });
        }
        break;
    }
    
    return plantsCopy;
  }

  Future<void> addPlant({
    required String name,
    String? variety,
    DateTime? purchaseDate,
    String? purchaseLocation,
    String? imagePath,
    int? wateringIntervalDays,
  }) async {
    final now = DateTime.now();
    final plant = Plant(
      id: const Uuid().v4(),
      name: name,
      variety: variety,
      purchaseDate: purchaseDate,
      purchaseLocation: purchaseLocation,
      imagePath: imagePath,
      wateringIntervalDays: wateringIntervalDays,
      createdAt: now,
      updatedAt: now,
    );

    if (kIsWeb) {
      await _web!.insertPlant(plant);
    } else {
      await _db!.insertPlant(plant);
    }
    await loadPlants();
  }

  Future<void> updatePlant(Plant plant) async {
    if (kIsWeb) {
      await _web!.updatePlant(plant);
    } else {
      await _db!.updatePlant(plant);
    }
    await loadPlants();
  }

  Future<void> deletePlant(String id) async {
    if (kIsWeb) {
      await _web!.deletePlant(id);
    } else {
      await _db!.deletePlant(id);
    }

    // Issue #12: 削除した植物IDをノートの plantIds から除去する
    await _removePlantIdFromNotes(id);

    await loadPlants();
  }

  /// 削除された植物IDを、参照しているすべてのノートの plantIds から除去する
  Future<void> _removePlantIdFromNotes(String plantId) async {
    try {
      if (kIsWeb) {
        // Web: WebStorageServiceの専用メソッドで一括処理
        await _web!.removePlantIdFromNotes(plantId);
      } else {
        final notes = await _db!.getAllNotes();
        for (final note in notes) {
          if (note.plantIds.contains(plantId)) {
            final updatedNote = note.copyWith(
              plantIds: note.plantIds.where((id) => id != plantId).toList(),
              updatedAt: DateTime.now(),
            );
            await _db.updateNote(updatedNote);
          }
        }
      }
    } catch (e) {
      debugPrint('Error removing plantId from notes: $e');
    }
  }

  Future<void> recordWatering(String plantId, DateTime date, String? note) async {
    // Add watering log
    final log = LogEntry(
      id: const Uuid().v4(),
      plantId: plantId,
      type: LogType.watering,
      date: date,
      note: note,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    if (kIsWeb) {
      await _web!.insertLog(log);
    } else {
      await _db!.insertLog(log);
    }

    // nextWateringDateは動的に計算するため、ここでは更新しない

    await loadPlants();
  }

  Future<void> recordFertilizer(String plantId, DateTime date, String? note) async {
    final log = LogEntry(
      id: const Uuid().v4(),
      plantId: plantId,
      type: LogType.fertilizer,
      date: date,
      note: note,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    if (kIsWeb) {
      await _web!.insertLog(log);
    } else {
      await _db!.insertLog(log);
    }

    await loadPlants();
  }

  Future<void> recordVitalizer(String plantId, DateTime date, String? note) async {
    final log = LogEntry(
      id: const Uuid().v4(),
      plantId: plantId,
      type: LogType.vitalizer,
      date: date,
      note: note,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    if (kIsWeb) {
      await _web!.insertLog(log);
    } else {
      await _db!.insertLog(log);
    }

    await loadPlants();
  }

  /// 複数植物 × 複数ログタイプの記録を一括挿入し、最後に loadPlants を。1回呼ぶ。
  /// 一括水やり登録時の画面チラツキを防止する (#50)。
  Future<void> bulkRecordLogs(
    List<String> plantIds,
    List<LogType> logTypes,
    DateTime date,
  ) async {
    final now = DateTime.now();
    for (final plantId in plantIds) {
      for (final logType in logTypes) {
        final log = LogEntry(
          id: const Uuid().v4(),
          plantId: plantId,
          type: logType,
          date: date,
          note: null,
          createdAt: now,
          updatedAt: now,
        );
        if (kIsWeb) {
          await _web!.insertLog(log);
        } else {
          await _db!.insertLog(log);
        }
      }
    }
    // 全挿入完了後に、1回だけ再読み込み
    await loadPlants();
  }

  // 動的に次回水やり日を計算（記録から算出）
  Future<DateTime?> calculateNextWateringDate(String plantId) async {
    Plant? plant;
    if (kIsWeb) {
      plant = await _web!.getPlant(plantId);
    } else {
      plant = await _db!.getPlant(plantId);
    }
    
    if (plant == null || plant.wateringIntervalDays == null) return null;

    // 最新の水やり記録を取得
    List<LogEntry> wateringLogs;
    if (kIsWeb) {
      wateringLogs = await _web!.getLogsByPlantAndType(plantId, LogType.watering);
    } else {
      wateringLogs = await _db!.getLogsByPlantAndType(plantId, LogType.watering);
    }

    if (wateringLogs.isEmpty) {
      // 記録がない場合は、購入日または作成日から計算
      final baseDate = plant.purchaseDate ?? plant.createdAt;
      return baseDate.add(Duration(days: plant.wateringIntervalDays!));
    }

    // 最新の記録から計算
    wateringLogs.sort((a, b) => b.date.compareTo(a.date));
    final lastWatering = wateringLogs.first;
    return lastWatering.date.add(Duration(days: plant.wateringIntervalDays!));
  }

  /// Gets logs for a specific plant and type on a specific date
  Future<List<LogEntry>> getLogsForDate(
    String plantId,
    LogType logType,
    DateTime date,
  ) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    List<LogEntry> logs;
    if (kIsWeb) {
      logs = await _web!.getLogsByPlantAndType(plantId, logType);
    } else {
      logs = await _db!.getLogsByPlantAndType(plantId, logType);
    }

    return logs.where((log) {
      return log.date.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
          log.date.isBefore(endOfDay.add(const Duration(seconds: 1)));
    }).toList();
  }

  /// Checks if a plant has any log of given type on a specific date
  Future<bool> hasLogOnDate(
    String plantId,
    LogType logType,
    DateTime date,
  ) async {
    final logs = await getLogsForDate(plantId, logType, date);
    return logs.isNotEmpty;
  }

  /// Deletes all logs of given type for a plant on a specific date
  Future<void> deleteLogsForDate(
    String plantId,
    LogType logType,
    DateTime date,
  ) async {
    final logs = await getLogsForDate(plantId, logType, date);
    for (final log in logs) {
      if (kIsWeb) {
        await _web!.deleteLog(log.id);
      } else {
        await _db!.deleteLog(log.id);
      }
    }
  }

  /// Deletes multiple log types for a plant on a specific date
  Future<void> deleteMultipleLogsForDate(
    String plantId,
    List<LogType> logTypes,
    DateTime date,
  ) async {
    for (final logType in logTypes) {
      await deleteLogsForDate(plantId, logType, date);
    }
  }

  /// Gets all logs for a specific plant and type (not filtered by date)
  Future<List<LogEntry>> getAllLogsForPlantAndType(
    String plantId,
    LogType logType,
  ) async {
    if (kIsWeb) {
      return await _web!.getLogsByPlantAndType(plantId, logType);
    } else {
      return await _db!.getLogsByPlantAndType(plantId, logType);
    }
  }

  /// Deletes a specific log by ID
  Future<void> deleteLog(String logId) async {
    if (kIsWeb) {
      await _web!.deleteLog(logId);
    } else {
      await _db!.deleteLog(logId);
    }
  }

  /// すべての植物の水やり間隔を指定した日数に一括設定する（interval が null の植物もセット）
  Future<void> bulkUpdateWateringInterval(int days) async {
    for (final plant in _plants) {
      final updated = Plant(
        id: plant.id,
        name: plant.name,
        variety: plant.variety,
        purchaseDate: plant.purchaseDate,
        purchaseLocation: plant.purchaseLocation,
        imagePath: plant.imagePath,
        wateringIntervalDays: days,
        createdAt: plant.createdAt,
        updatedAt: DateTime.now(),
      );
      if (kIsWeb) {
        await _web!.updatePlant(updated);
      } else {
        await _db!.updatePlant(updated);
      }
    }
    await loadPlants();
  }

  /// 水やり間隔が設定されている植物のみ、現在値に delta を加算して一括調整する
  /// 結果は最低 1 日にクランプする
  Future<void> bulkAdjustWateringInterval(int delta) async {
    for (final plant in _plants) {
      if (plant.wateringIntervalDays == null) continue;
      final newDays = (plant.wateringIntervalDays! + delta).clamp(1, 9999);
      final updated = Plant(
        id: plant.id,
        name: plant.name,
        variety: plant.variety,
        purchaseDate: plant.purchaseDate,
        purchaseLocation: plant.purchaseLocation,
        imagePath: plant.imagePath,
        wateringIntervalDays: newDays,
        createdAt: plant.createdAt,
        updatedAt: DateTime.now(),
      );
      if (kIsWeb) {
        await _web!.updatePlant(updated);
      } else {
        await _db!.updatePlant(updated);
      }
    }
    await loadPlants();
  }
}
