import '../models/log_entry.dart';

/// Manages log status for plants on a specific date
class DailyLogStatus {
  final Map<String, bool> _watered;
  final Map<String, bool> _fertilized;
  final Map<String, bool> _vitalized;

  DailyLogStatus({
    required Map<String, bool> watered,
    required Map<String, bool> fertilized,
    required Map<String, bool> vitalized,
  })  : _watered = watered,
        _fertilized = fertilized,
        _vitalized = vitalized;

  factory DailyLogStatus.empty() {
    return DailyLogStatus(
      watered: {},
      fertilized: {},
      vitalized: {},
    );
  }

  bool isWatered(String plantId) => _watered[plantId] ?? false;
  bool isFertilized(String plantId) => _fertilized[plantId] ?? false;
  bool isVitalized(String plantId) => _vitalized[plantId] ?? false;
  bool hasAnyLog(String plantId) =>
      isWatered(plantId) || isFertilized(plantId) || isVitalized(plantId);

  int get wateredCount => _watered.values.where((v) => v).length;
  int get fertilizedCount => _fertilized.values.where((v) => v).length;
  int get vitalizedCount => _vitalized.values.where((v) => v).length;
  bool get hasAnyRecords =>
      wateredCount > 0 || fertilizedCount > 0 || vitalizedCount > 0;

  /// Updates status for a specific plant and log type
  void updateStatus(String plantId, LogType logType, bool value) {
    switch (logType) {
      case LogType.watering:
        _watered[plantId] = value;
        break;
      case LogType.fertilizer:
        _fertilized[plantId] = value;
        break;
      case LogType.vitalizer:
        _vitalized[plantId] = value;
        break;
    }
  }

  /// Checks if plant has logs other than the specified type
  bool hasOtherLogs(String plantId, LogType excludeType) {
    switch (excludeType) {
      case LogType.watering:
        return isFertilized(plantId) || isVitalized(plantId);
      case LogType.fertilizer:
        return isWatered(plantId) || isVitalized(plantId);
      case LogType.vitalizer:
        return isWatered(plantId) || isFertilized(plantId);
    }
  }

  /// Gets all log types that have records for a plant
  List<LogType> getActiveLogTypes(String plantId) {
    final types = <LogType>[];
    if (isWatered(plantId)) types.add(LogType.watering);
    if (isFertilized(plantId)) types.add(LogType.fertilizer);
    if (isVitalized(plantId)) types.add(LogType.vitalizer);
    return types;
  }

  Map<String, bool> get wateredMap => Map.unmodifiable(_watered);
  Map<String, bool> get fertilizedMap => Map.unmodifiable(_fertilized);
  Map<String, bool> get vitalizedMap => Map.unmodifiable(_vitalized);
}
