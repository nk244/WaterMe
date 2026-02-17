import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/plant.dart';
import '../models/log_entry.dart';
import '../services/database_service.dart';
import '../services/memory_storage_service.dart';

class PlantProvider with ChangeNotifier {
  final _db = kIsWeb ? null : DatabaseService();
  final _memory = kIsWeb ? MemoryStorageService() : null;
  List<Plant> _plants = [];
  bool _isLoading = false;

  List<Plant> get plants => _plants;
  bool get isLoading => _isLoading;

  Future<void> loadPlants() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (kIsWeb) {
        _plants = await _memory!.getAllPlants();
      } else {
        _plants = await _db!.getAllPlants();
      }
    } catch (e) {
      debugPrint('Error loading plants: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
      nextWateringDate: wateringIntervalDays != null
          ? now.add(Duration(days: wateringIntervalDays))
          : null,
      createdAt: now,
      updatedAt: now,
    );

    if (kIsWeb) {
      await _memory!.insertPlant(plant);
    } else {
      await _db!.insertPlant(plant);
    }
    await loadPlants();
  }

  Future<void> updatePlant(Plant plant) async {
    if (kIsWeb) {
      await _memory!.updatePlant(plant);
    } else {
      await _db!.updatePlant(plant);
    }
    await loadPlants();
  }

  Future<void> deletePlant(String id) async {
    if (kIsWeb) {
      await _memory!.deletePlant(id);
    } else {
      await _db!.deletePlant(id);
    }
    await loadPlants();
  }

  Future<void> recordWatering(String plantId, DateTime date, String? note) async {
    final Plant? plant;
    if (kIsWeb) {
      plant = await _memory!.getPlant(plantId);
    } else {
      plant = await _db!.getPlant(plantId);
    }
    
    if (plant == null) return;

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
      await _memory!.insertLog(log);
    } else {
      await _db!.insertLog(log);
    }

    // Update next watering date
    if (plant.wateringIntervalDays != null) {
      final updatedPlant = plant.copyWith(
        nextWateringDate: date.add(Duration(days: plant.wateringIntervalDays!)),
        updatedAt: DateTime.now(),
      );
      if (kIsWeb) {
        await _memory!.updatePlant(updatedPlant);
      } else {
        await _db!.updatePlant(updatedPlant);
      }
    }

    await loadPlants();
  }
}
