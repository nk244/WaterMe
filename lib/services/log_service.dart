import '../models/log_entry.dart';

/// Service for plant log operations
/// Provides abstraction layer over storage services
class LogService {
  final dynamic _storage;

  LogService(this._storage);

  /// Gets logs for a specific plant and log type on a specific date
  Future<List<LogEntry>> getLogsForDate(
    String plantId,
    LogType logType,
    DateTime date,
  ) async {
    final logs = await _storage.getLogsByPlantAndType(plantId, logType);
    return _filterLogsByDate(logs, date);
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
      await _storage.deleteLog(log.id);
    }
  }

  /// Filters logs to only include those on the specified date
  List<LogEntry> _filterLogsByDate(List<LogEntry> logs, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return logs.where((log) {
      return log.date.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
          log.date.isBefore(endOfDay.add(const Duration(seconds: 1)));
    }).toList();
  }
}
